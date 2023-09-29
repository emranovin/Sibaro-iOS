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
    
    var localServer: HttpServer?
    
    private func install(ipaURL: String,
                         iconURL: String,
                         bundleID: String,
                         version: String,
                         name: String) {
        var manifest = "https://api.seebaro.ir/api/manifest.plist?ipa_url=\(ipaURL)&icon_url=\(iconURL)&bundle_identifier=\(bundleID)&bundle_version=\(version)&bundle_name=\(name.encodedURIComponents)"
        manifest = manifest.encodedURIComponents
        let url = "itms-services://?action=download-manifest&url=\(manifest)"
        print(url)
        openURL(URL(string: url)!)
    }
    
    func signAndInstall(ipaURL: URL) throws {
        let signedIPAURL = Directory.installing.url.appendingPathComponent("app.ipa")
        let iconURL = Directory.installing.url.appendingPathComponent("icon.png")
        try? FileManager.default.removeItem(at: signedIPAURL)
        try? FileManager.default.removeItem(at: iconURL)
        let ipaProperties = try signer.resign(sourceIPAURL: ipaURL, signedIPAURL: signedIPAURL)
        try ipaProperties.icon?.write(to: iconURL)
        startServer()
        install(ipaURL: "http://localhost:8081/app.ipa",
                iconURL: ipaProperties.icon == nil ? "" : "http://localhost:8081/icon.png",
                bundleID: ipaProperties.bundleID,
                version: ipaProperties.version,
                name: ipaProperties.name)
    }
    
    private func startServer() {
        localServer = HttpServer()
        localServer?["/:path"] = shareFilesFromDirectory(Directory.installing.url.path)
        do {
            try localServer?.start(8081)
        } catch {
            stopServer()
        }
    }
    
    // FIXME: Call this in proper place
    private func stopServer() {
        localServer?.stop()
    }
}
