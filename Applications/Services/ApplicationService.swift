//
//  ApplicationService.swift
//  AppExplorer
//
//  Created by Cardasis, Jonathan (J.) on 7/13/16.
//  Copyright © 2016 Cardasis, Jonathan (J.). All rights reserved.
//

protocol ApplicationServicable: BaseService {
    func getAppState(_ product: Product) -> InstallationState
    @discardableResult func openApplication(_ bundleID: String?) -> Bool
}

#if os(iOS)
import Foundation

class ApplicationService: BaseService, ApplicationServicable {
    fileprivate var workspace: LSApplicationWorkspace?
    
    override init() {
        workspace = LSApplicationWorkspace.defaultWorkspace() as? LSApplicationWorkspace
        super.init()
        allInstalledApplications()
    }

    func getAppState(_ product: Product) -> InstallationState {
        
        guard
            let installedVersion = systemApplications?[product.bundleIdentifier]?.version
        else {
            return .install
        }
        
        return product.version.isBigger(than: installedVersion) ? .update : .open
    }
    
    @Published var systemApplications: [String: SystemApplication]?
    
    @discardableResult
    func allInstalledApplications(refresh: Bool = false) -> [String: SystemApplication] {
        if !refresh, let systemApplications {
            return systemApplications
        }
        guard let workspace = workspace else { //protect
            return [:]
        }
        var applications = [String: SystemApplication]()
        let installedApplicationProxies = workspace.allInstalledApplications() as! [LSApplicationProxy]
        
        for applicationProxy in installedApplicationProxies {
            
            let bundleIdentifier = applicationProxy.bundleIdentifier
            let appIcon = self.applicationIconImageForBundleIdentifier(bundleIdentifier!)
            
            /* Create and map a system application object to LSApplicationProxys variables */
            let app = SystemApplication()
            app.map(bundleID: bundleIdentifier,
                    name: applicationProxy.localizedName,
                    version: applicationProxy.shortVersionString,
                    executableName: applicationProxy.bundleExecutable,
                    type: applicationProxy.applicationType,
                    signerIdentity: applicationProxy.signerIdentity,
                    applicationPath: applicationProxy.dataContainerURL,
                    backgroundModes: applicationProxy.uiBackgroundModes as? [String],
                    icon: appIcon
            )
            applications[app.bundleID!] = app
        }
        systemApplications = applications
        return applications
    }
    
    
    @discardableResult func openApplication(_ bundleID: String?) -> Bool {
        if let workspace = workspace {
            return workspace.openApplication(withBundleID: bundleID)
        }
        return false
    }
    
    @discardableResult func openApplication(bundleID: String) -> Bool {
        if let workspace = workspace {
            return workspace.openApplication(withBundleID: bundleID)
        }
        return false
    }
    
    func applicationIconImageForBundleIdentifier(_ bundleID: String) -> UIImage?{
        //Format of 2 will return a 62x62 image
        return UIImage._applicationIconImage(forBundleIdentifier: bundleID, format: 2
            , scale: Double(UIScreen.main.scale)) as? UIImage
    }
    
}

#else
class ApplicationService: BaseService, ApplicationServicable {
    func getAppState(_ product: Product) -> InstallationState {
        return .install
    }
    
    func openApplication(_ bundleID: String?) -> Bool {
        return false
    }
}
#endif
