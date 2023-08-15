//
//  AuthEndpoint.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import Foundation

enum AuthEndpoint {
    case login(
        username: String,
        password: String
    )
}

extension AuthEndpoint: Endpoint {
    var path: String {
        switch self {
        case .login(_, _):
            return "/api/token/"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login(_, _):
            return .post
        }
    }
    
    var needsToken: Bool {
        switch self {
        case .login(_, _):
            return false
        }
    }
    
    var header: [String : String]? {
        return ["Content-Type" : "application/json; charset=utf-8"]
    }
    
    var urlParams: [URLQueryItem]? {
        return nil
    }
    
    var body: [String : Any]? {
        switch self {
        case .login(let username, let password):
            return [
                "username": username,
                "password": password
            ]
        }
    }
}
