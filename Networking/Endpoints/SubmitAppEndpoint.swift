//
//  SubmitAppEndpoint.swift
//  Sibaro
//
//  Created by Soroush Arasteh on 8/14/23.
//

import Foundation

enum SubmitAppEndpoint {
    case appSuggestion(
        name: String,
        link: String?,
        description: String?
    )
}

extension SubmitAppEndpoint: Endpoint {
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
    
    var needsToken: Bool {
        switch self {
        case .appSuggestion:
            return true
        }
    }
    
    var header: [String : String]? {
        switch self {
        case .appSuggestion:
            return [
                "Content-Type" : "application/json; charset=utf-8"
            ]
        }
        
    }
    
    var urlParams: [URLQueryItem]? {
        return nil
    }
    
    var body: [String : Any]? {
        switch self {
        case .appSuggestion(let name, let link, let description):
            return [
                "name": name,
                "link": link ?? "",
                "description" : description ?? ""
            ]
        }
    }
}
