//
//  ProductsEndpoint.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import Foundation

enum ProductsEndpoint {
    case applications(token: String)
    case appManifest(id: Int, token: String)
}

extension ProductsEndpoint: Endpoint {
    var path: String {
        switch self {
        case .applications:
            return "/api/applications/"
        case .appManifest(let id, _):
            return "/api/applications/\(id)/"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var header: [String : String]? {
        switch self {
        case .applications(let token),
             .appManifest(_, let token):
            return [
                "Content-Type" : "application/json; charset=utf-8",
                "Authorization": token
            ]
        }
        
    }
    
    var urlParams: [URLQueryItem]? {
        return nil
    }
    
    var body: [String : Any]? {
        return nil
    }
}
