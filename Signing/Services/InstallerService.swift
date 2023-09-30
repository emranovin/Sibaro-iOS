//
//  InstallerService.swift
//  Sibaro
//
//  Created by Emran Novin on 9/29/23.
//

import Foundation
import Swifter

protocol InstallerServicable: BaseService {
    func signAndInstall(ipaURL: URL) throws
}

class InstallerService: BaseService, InstallerServicable {
    
    @Injected(\.openURL) var openURL
    @Injected(\.signer) var signer
    
    private var localServer: HttpServer?
    
    private var installerIPA: URL {
        Directory.installing.url.appendingPathComponent("app.ipa")
    }
    private var installerIcon: URL {
        Directory.installing.url.appendingPathComponent("icon.png")
    }
    
    private let port: UInt16 = 8083
        
    private func install(ipaURL: String,
                         iconURL: String,
                         bundleID: String,
                         version: String,
                         name: String) {
        guard
            var components = URLComponents(
                string: "https://\(SibaroAPI.url)/api/manifest.plist"
            )
        else {
            return
        }
        components.queryItems = [
            URLQueryItem(name: "ipa_url", value: ipaURL),
            URLQueryItem(name: "icon_url", value: iconURL),
            URLQueryItem(name: "bundle_identifier", value: bundleID),
            URLQueryItem(name: "bundle_version", value: version),
            URLQueryItem(name: "bundle_name", value: name)
        ]
        guard
            let manifestURL = components.url?.absoluteString,
            var components = URLComponents(string: "itms-services://?action=download-manifest"),
            let _ = components.queryItems // Check if it's parsed correctly
        else {
            return
        }
        components.queryItems?.append(
            URLQueryItem(name: "url", value: manifestURL)
        )
        guard let url = components.url else {
            return
        }
        openURL(url)
    }
    
    func signAndInstall(ipaURL: URL) throws {
        try? FileManager.default.removeItem(at: installerIPA)
        try? FileManager.default.removeItem(at: installerIcon)
        let ipaProperties = try signer.resign(sourceIPAURL: ipaURL, signedIPAURL: installerIPA)
        try ipaProperties.icon?.write(to: installerIcon)
        startServer()
        install(ipaURL: "http://localhost:8081/app.ipa",
                iconURL: ipaProperties.icon == nil ? "" : "http://localhost:8081/icon.png",
                bundleID: ipaProperties.bundleID,
                version: ipaProperties.version,
                name: ipaProperties.name)
    }
    
    private func startServer() {
        localServer = HttpServer()
        localServer?["/:path"] = fileShareRequestHandler(Directory.installing.url.path, completed: { [weak self] request in
            if request.path.contains(".ipa") {
                self?.stopServer()
            }
        })
        do {
            try localServer?.start(port, priority: .userInitiated)
        } catch {
            stopServer()
        }
    }
    
    private func stopServer() {
        // TODO: - We need to see if the IPA is installed, then close the server
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 10) { [weak self] () in
            guard let self else { return }
            localServer?.stop()
            try? FileManager.default.removeItem(at: installerIPA)
            try? FileManager.default.removeItem(at: installerIcon)
            localServer = nil
        }
    }
}
