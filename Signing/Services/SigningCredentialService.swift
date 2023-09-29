//
//  SigningCredentialService.swift
//  Sibaro
//
//  Created by Emran Novin on 9/27/23.
//

import CryptoKit
import SimpleKeychain
import ZIPFoundation
import ZSign

enum SigningCredentialsState {
    case loading
    case loaded
    case error(Error)
}

protocol SignerServicable: BaseService {
    var state: SigningCredentialsState { get }
    var p12Password: String? { get }
    func getCredentials() async throws
    func resign(sourceIPAURL: URL, signedIPAURL: URL) throws -> IPAProperties
}

class SignerService: BaseService, SignerServicable {
    
    @Injected(\.storage) var storage
    @Injected(\.authRepository) var auth
    @Published var state: SigningCredentialsState = .loading
    
    private(set) var p12Password: String?
    
    func getCredentials() {
        state = .loading
        Task {
            do {
                try await _getCredentials()
                state = .loaded
            } catch {
                state = .error(error)
            }
        }
    }
    
    private func _getCredentials() async throws {
        
        // Generate a DH key pair
        guard let keyPair = getKeyPair() else { throw SigningCredentialsError.generateKeyPair }
        
        // Send `myPublicKey` to the server and receive the server's public key
        let signingCredentials = try await auth.getSigningCredentials(publicKey: keyPair.publicKey.pemRepresentation)
        let serverPublicKey = try! P256.KeyAgreement.PublicKey(pemRepresentation: signingCredentials.publicKey)
        
        // Compute the shared secret
        let sharedSecret = try! keyPair.privateKey.sharedSecretFromKeyAgreement(with: serverPublicKey)
        
        // Derive a symmetric key from the shared secret
        let symmetricKeyData: Data = sharedSecret.withUnsafeBytes { return Data($0) }
        
        // Hash the symmetric key to derive the password
        let passwordData = SHA256.hash(data: symmetricKeyData).prefix(32)
        p12Password = passwordData.map { String(format: "%02hhx", $0) }.joined()
        guard let p12Data = Data(base64Encoded: signingCredentials.p12),
              let certData = Data(base64Encoded: signingCredentials.cert),
              let profileData = Data(base64Encoded: signingCredentials.profile)
        else {
            throw SigningCredentialsError.badFormat
        }
        storage.p12.save(data: p12Data)
        storage.cert.save(data: certData)
        storage.profile.save(data: profileData)
    }
    
    func getKeyPair(recreate: Bool = false) -> (privateKey: P256.KeyAgreement.PrivateKey,
                                                publicKey: P256.KeyAgreement.PublicKey)? {
        
        if recreate {
            // Delete existing keys if you want to recreate
            storage.privateKey = nil
            storage.publicKey = nil
        }
        
        // Check if keys already exist in the keychain
        if let privateKeyB64 = storage.privateKey,
           let publicKeyB64 = storage.publicKey,
           let privateKeyData = Data(base64Encoded: privateKeyB64),
           let publicKeyData = Data(base64Encoded: publicKeyB64) {
            
            let privateKey = try? P256.KeyAgreement.PrivateKey(rawRepresentation: privateKeyData)
            let publicKey = try? P256.KeyAgreement.PublicKey(rawRepresentation: publicKeyData)
            
            if let privateKey = privateKey, let publicKey = publicKey {
                return (privateKey, publicKey)
            }
        }
        
        // Generate new keys if they don't exist
        let privateKey = P256.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey
        
        // Save the keys to the keychain
        storage.privateKey = privateKey.rawRepresentation.base64EncodedString()
        storage.publicKey = publicKey.rawRepresentation.base64EncodedString()
        
        return (privateKey, publicKey)
    }
    
    func resign(sourceIPAURL: URL, signedIPAURL: URL) throws -> IPAProperties {
        let fileManager = FileManager.default
        let uuid = UUID().uuidString
        let destinationURL = Directory.temp.url.appendingPathComponent(uuid, isDirectory: true)
        
        defer {
            try? fileManager.removeItem(at: destinationURL)
        }
        
        print("Let's do this shit")
        try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
        try fileManager.unzipItem(at: sourceIPAURL, to: destinationURL)
        
        print("Extract done")
        
        let properties = try getIPAProperties(ipaURL: destinationURL)
        
        guard resign(sourcePath: destinationURL.path) == 0 else {
            throw SigningError.resign
        }
        
        try fileManager.zipItem(at: destinationURL.appendingPathComponent("Payload"), to: signedIPAURL)
        
        print("IPA saved at \(signedIPAURL.path)")
        
        return properties
    }
    
    private func getIPAProperties(ipaURL: URL) throws -> IPAProperties {
        let payloadURL = ipaURL.appendingPathComponent("Payload")
        guard let appName = try FileManager.default.contentsOfDirectory(atPath: payloadURL.path).first(where: { $0.lowercased().hasSuffix(".app") }) else {
            throw SigningError.appFolderMissing
        }
        let appURL = payloadURL.appendingPathComponent(appName)
        let infoURL = appURL.appendingPathComponent("Info.plist")
        guard let infoPlist = NSDictionary(contentsOfFile: infoURL.path),
              let bundleName = infoPlist["CFBundleName"] as? String,
              let bundleVersion = infoPlist["CFBundleVersion"] as? String,
              let bundleID = infoPlist["CFBundleIdentifier"] as? String
        else {
            throw SigningError.invalidInfoPlist
        }
        var icon: Data?
        if let iconName = try? FileManager.default.contentsOfDirectory(atPath: appURL.path).sorted().last(where: { $0.lowercased().hasPrefix("appicon")}) {
            icon = try? Data(contentsOf: appURL.appendingPathComponent(iconName))
        }
        return IPAProperties(name: bundleName, version: bundleVersion, bundleID: bundleID, icon: icon)
    }
    
    private func resign(sourcePath: String) -> Int32 {
        return zsign(
            sourcePath,
            storage.cert.url.path,
            storage.p12.url.path,
            storage.profile.url.path,
            p12Password
        )
    }
}
