//
//  DesiredAppEndpoint.swift
//  Sibaro
//
//  Created by Soroush Arasteh on 8/14/23.
//

import Foundation

enum DesiredAppEndpoint {
    case appSuggestion(
        token: String,
        name: String,
        link: String?,
        description: String?
    )
}

extension DesiredAppEndpoint: Endpoint {
    var path: String {
        switch self {
        case .appSuggestion:
            return "/api/suggestions/"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .appSuggestion:
            return .post
        }
    }
    
    var header: [String : String]? {
        switch self {
        case .appSuggestion(let token, _, _, _):
            return ["Content-Type" : "application/json; charset=utf-8",
                    "Authorization" : token]
        }
    }
    
    var urlParams: [URLQueryItem]? {
        return nil
    }
    
    var body: [String : Any]? {
        switch self {
        case .appSuggestion(_, let name, let link, let description):
            return [
                "name": name,
                "link": link ?? "",
                "description" : description ?? ""
            ]
        }
    }
}
