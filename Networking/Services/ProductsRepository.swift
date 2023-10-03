//
//  ProductsService.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import Foundation
import DependencyFactory

protocol ProductsRepositoryType {
    func products() async throws -> [Product]
    func getManifest(id: Int) async throws -> URL?
}

class ProductsRepository: BaseService, HTTPClient, ProductsRepositoryType {
    @Injected(\.storage) var storage
    
    func products() async throws -> [Product] {
        return try await sendRequest(
            endpoint: ProductsEndpoint.applications,
            responseModel: [Product].self
        )
    }
    
    func getManifest(id: Int) async throws -> URL? {
        let response = try await sendRequest(
            endpoint: ProductsEndpoint.appManifest(id: id),
            responseModel: AppManifest.self
        )
        
        return response.url
    }
}
