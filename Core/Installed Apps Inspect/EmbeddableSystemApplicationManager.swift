//
//  EmbeddableSystemApplicationManager.swift
//  AppExplorer
//
//  Created by Jonathan Cardasis on 8/8/16.
//  Copyright © 2016 Cardasis, Jonathan (J.). All rights reserved.
//

import UIKit
import Foundation


//Reverse-Engineered interface for LSApplicationWorkspace
@objc private protocol LSApplicationWorkspace_Interface{
    @objc func defaultWorkspace()-> LSApplicationWorkspace_Interface
    @objc func allInstalledApplications() -> [NSObject]
    @objc func openApplicationWithBundleID(bundleID: AnyObject!) -> Bool
}
@objc private protocol UIImage_Private_Interface{
    @objc func _applicationIconImageForBundleIdentifier(bundleID: AnyObject!, format: AnyObject!, scale: AnyObject!)
}

//Reverse-Engineered calls and variables
private struct ReversedCall{
    struct LSApplicationWorkspace {
        struct Selector{
            static let workspace = #selector(LSApplicationWorkspace_Interface.defaultWorkspace)
            static let getAllInstalledApplications = #selector(LSApplicationWorkspace_Interface.allInstalledApplications)
            static let openApplicationWithBundleID = #selector(LSApplicationWorkspace_Interface.openApplicationWithBundleID)
        }
    }
    
    struct LSApplicationProxy {
        static let bundleIdentifier     = "bundleIdentifier"
        static let localizedName        = "localizedName"
        static let shortVersionString   = "shortVersionString"
        static let bundleExecutable     = "bundleExecutable"
        static let applicationType      = "applicationType"
        static let signerIdentity       = "signerIdentity"
        static let dataContainerURL     = "dataContainerURL"
        static let UIBackgroundModes    = "UIBackgroundModes"
    }
    
    struct UIImage{
        static let applicationIconImageForBundleIdentifier = #selector(UIImage_Private_Interface._applicationIconImageForBundleIdentifier)
    }
}


class EmbeddableSystemApplicationManager: NSObject {
    static let sharedManager = EmbeddableSystemApplicationManager()
    private var workspace: NSObject? //LSApplicationWorkspace
    
    private let LSApplicationWorkspace_class: AnyClass! = NSClassFromString("LSApplicationWorkspace")
    
    override init(){
        //Setup workspace
        if let myClass =  LSApplicationWorkspace_class as? NSObjectProtocol {
            if myClass.responds(to: ReversedCall.LSApplicationWorkspace.Selector.workspace) {
                self.workspace = myClass.perform(ReversedCall.LSApplicationWorkspace.Selector.workspace).takeRetainedValue() as? NSObject
            }
        }
    }
    
    
    func allInstalledApplications() -> [SystemApplication]{
        guard let workspace = workspace else{
            return []
        }

        guard workspace.responds(to: ReversedCall.LSApplicationWorkspace.Selector.getAllInstalledApplications) == true else{
            return []
        }
        var applications = [SystemApplication]()
        
        //Take an Unretained value so ARC doesn't release the workspace's installed apps array
        if let installedApplicationProxies = workspace.perform(ReversedCall.LSApplicationWorkspace.Selector.getAllInstalledApplications).takeUnretainedValue() as? Array<AnyObject> {
        
            for installedApp in installedApplicationProxies{
                guard let bundleID = installedApp.value(forKey: ReversedCall.LSApplicationProxy.bundleIdentifier) as? String else{
                    return applications
                }
                
                let appIcon = self.applicationIconImageForBundleIdentifier(bundleID: bundleID)
                
                let app = SystemApplication()
                app.map(bundleID: bundleID,
                        name: installedApp.value(forKey: ReversedCall.LSApplicationProxy.localizedName) as? String,
                        version: installedApp.value(forKey: ReversedCall.LSApplicationProxy.shortVersionString) as? String,
                        executableName: installedApp.value(forKey: ReversedCall.LSApplicationProxy.bundleExecutable) as? String,
                        type: installedApp.value(forKey: ReversedCall.LSApplicationProxy.applicationType) as? String,
                        signerIdentity: installedApp.value(forKey: ReversedCall.LSApplicationProxy.signerIdentity) as? String,
                        applicationPath: installedApp.value(forKey: ReversedCall.LSApplicationProxy.dataContainerURL) as? URL,
                        backgroundModes: installedApp.value(forKey: ReversedCall.LSApplicationProxy.UIBackgroundModes) as? [String],
                        icon: appIcon
                )
                applications.append(app)
            }
        }
        return applications
    }
    
    @discardableResult func openApplication(app: SystemApplication) -> Bool {
        if let bundleID = app.bundleID{
            return self.openApplication(bundleID: bundleID)
        }
        return false
    }
    
    @discardableResult func openApplication(bundleID: String) -> Bool {
        if let workspace = workspace, workspace.responds(to: ReversedCall.LSApplicationWorkspace.Selector.openApplicationWithBundleID){
            if workspace.perform(ReversedCall.LSApplicationWorkspace.Selector.openApplicationWithBundleID, with: bundleID) != nil{
                return true //Not entirely accurate, but probably opened
            }
        }
        return false
    }

    func applicationIconImageForBundleIdentifier(bundleID: String) -> UIImage?{
        let appIconSelector = ReversedCall.UIImage.applicationIconImageForBundleIdentifier
        //Selector format is (bundleID: String, format: Int, scale: Double) - format 2 will return a 62x62 image

        return Invocator.performClassSelector(appIconSelector, target: UIImage.self, args: [bundleID, 2, Double(UIScreen.main.scale)]) as? UIImage
    }
}

