//
//  ProductsService.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import Foundation

protocol ProductsRepositoryType {
    func products() async throws -> [Product]
    func getManifest(id: Int) async throws -> URL?
    func filterProducts(
        search: String,
        ordering: Product.OrderProperty,
        type: AppType,
        cursor: String
    ) async throws -> ProductsPage
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
    
    func filterProducts(
        search: String,
        ordering: Product.OrderProperty,
        type: AppType,
        cursor: String
    ) async throws -> ProductsPage {
        return try await sendRequest(
            endpoint: ProductsEndpoint.productPage(
                search: search,
                ordering: ordering,
                type: type,
                cursor: cursor
            ),
            responseModel: ProductsPage.self)
    }
}
