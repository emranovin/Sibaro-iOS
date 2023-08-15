//
//  SibaroAppServices.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/24/1402 AP.
//

import Foundation

// MARK: - Services
extension Container {
    var i18n: Factory<I18nServicable> {
        self { I18nService() }
    }
    
    var storage: Factory<StorageServicable> {
        self { StorageService() }
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
