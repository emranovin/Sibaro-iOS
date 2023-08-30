//
//  ProductsEndpoint.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import Foundation

enum ProductsEndpoint {
    case applications
    case appManifest(id: Int)
    case productPage(
        search: String,
        ordering: Product.OrderProperty,
        type: AppType,
        cursor: String
    )
}

extension Product {
    enum OrderProperty: String {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case title = "title"
    }
}

extension ProductsEndpoint: Endpoint {
    var path: String {
        switch self {
        case .applications:
            return "/api/applications/"
        case .appManifest(let id):
            return "/api/applications/\(id)/"
        case .productPage:
            return "/api/applications/filter/"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var needsToken: Bool {
        return true
    }
    
    var header: [String : String]? {
        switch self {
        case .applications,
                .appManifest, .productPage:
            return [
                "Content-Type" : "application/json; charset=utf-8"
            ]
        }
    }
    
    var urlParams: [URLQueryItem]? {
        switch self {
        case .productPage(let search, let ordering, let type, let cursor):
            return [
                URLQueryItem(name: "search", value: search),
                URLQueryItem(name: "ordering", value: ordering.rawValue),
                URLQueryItem(name: "type", value: type.rawValue),
                URLQueryItem(name: "cursor", value: cursor)
            ]
        default:
            return nil
        }
    }
    
    var body: [String : Any]? {
        return nil
    }
}
