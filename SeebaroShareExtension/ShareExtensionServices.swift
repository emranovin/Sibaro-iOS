//
//  ShareExtensionServices.swift
//  Sibaro
//
//  Created by AminRa on 7/10/1402 AP.
//

import Foundation
import DependencyFactory

#if os(iOS)
import UIKit
#else
import Cocoa
#endif

// MARK: - Services
extension Container {
    var i18n: Factory<I18nServicable> {
        Factory(self) { I18nService() }
    }
    
    var storage: Factory<StorageServicable> {
        Factory(self) { StorageService() }
    }
        
    var signer: Factory<SignerServicable> {
        Factory(self) { SignerService() }
    }
    
    var installer: Factory<InstallerService> {
        Factory(self) { InstallerService() }
    }
}


// MARK: - Repositories
extension Container {
    var authRepository: Factory<AuthRepositoryType> {
        Factory(self) { AuthRepository() }
    }
}

// MARK: - Functions
extension Container {
    var openURL: Factory<(_ url: URL) -> ()> {
        Factory(self) {
            { url in
                #if os(iOS)
                //TODO: implement open(url) for share extension
                //UIApplication.shared.open(url)
                #else
                NSWorkspace.shared.open(url)
                #endif
            }
        }
    }
}
