//
//  SibaroAppServices.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/24/1402 AP.
//

import Foundation
#if os(iOS)
import UIKit
#else
import Cocoa
#endif

// MARK: - Services
extension Container {
    var i18n: Factory<I18nServicable> {
        self { I18nService() }
    }
    
    var storage: Factory<StorageServicable> {
        self { StorageService() }
    }
    
    var applications: Factory<ApplicationServicable> {
        self { ApplicationService() }
    }
}


// MARK: - Repositories
extension Container {
    var authRepository: Factory<AuthRepositoryType> {
        self { AuthRepository() }
    }
    
    var productRepository: Factory<ProductsRepositoryType> {
        self { ProductsRepository() }
    }
}

// MARK: - Functions
extension Container {
    var openURL: Factory<(_ url: URL) -> Bool> {
        self {
            #if os(iOS)
            UIApplication.shared.openURL
            #else
            NSWorkspace.shared.open
            #endif
        }
    }
}
