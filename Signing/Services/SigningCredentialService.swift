//
//  SigningCredentialService.swift
//  Sibaro
//
//  Created by Emran Novin on 9/27/23.
//

import CryptoKit
import SimpleKeychain

protocol SigningCredentialsServicable: BaseService {
    func getCredentials() async throws
}

class SigningCredentialsService: BaseService, SigningCredentialsServicable {
    
    @Injected(\.storage) var storage
    @Injected(\.authRepository) var auth
    
    var privateKeyPassword: String?
    
    func getCredentials() async throws {
        // Generate a DH key pair
        guard let keyPair = getKeyPair() else { throw SigningError.generateKeyPair }
        
        // Send `myPublicKey` to the server and receive the server's public key
        let signingCredentials = try await auth.getSigningCredentials(publicKey: keyPair.publicKey.pemRepresentation)
        let serverPublicKey = try! P256.KeyAgreement.PublicKey(pemRepresentation: signingCredentials.publicKey)

        // Compute the shared secret
        let sharedSecret = try! keyPair.privateKey.sharedSecretFromKeyAgreement(with: serverPublicKey)

        // Derive a symmetric key from the shared secret
        let symmetricKeyData: Data = sharedSecret.withUnsafeBytes { return Data($0) }

        // Hash the symmetric key to derive the password
        let passwordData = SHA256.hash(data: symmetricKeyData).prefix(32)
        privateKeyPassword = passwordData.map { String(format: "%02hhx", $0) }.joined()
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
}
