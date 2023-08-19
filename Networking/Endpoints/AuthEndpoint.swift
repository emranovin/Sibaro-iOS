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
    case changePassword(
        oldPassword: String,
        newPassword: String
    )
    case verifyPassword(
        password: String
    )
}

extension AuthEndpoint: Endpoint {
    var path: String {
        switch self {
        case .login(_, _):
            return "/api/token/"
        case .changePassword(_, _):
            return "/api/password/change/"
        case .verifyPassword(_):
            return "/api/password/verify/"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login(_, _):
            return .post
        case .changePassword(_, _):
            return .post
        case .verifyPassword(_):
            return .post
        }
    }
    
    var needsToken: Bool {
        switch self {
        case .login(_, _):
            return false
        case .changePassword(_, _):
            return true
        case .verifyPassword(_):
            return true
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
        case .changePassword(let oldPassword, let newPassword):
            return [
                "old_password": oldPassword,
                "new_password": newPassword,
            ]
        case .verifyPassword(password: let password):
            return [
                "password": password
            ]
        }
    }
}
