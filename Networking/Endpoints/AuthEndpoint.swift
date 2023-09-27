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
    case getSigningCredentials(
        publicKey: String
    )
}

extension AuthEndpoint: Endpoint {
    var path: String {
        switch self {
        case .login:
            return "/api/token/"
        case .changePassword:
            return "/api/password/change/"
        case .verifyPassword:
            return "/api/password/verify/"
        case .getSigningCredentials:
            return "/api/sign-credentials/"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .changePassword:
            return .post
        case .verifyPassword:
            return .post
        case .getSigningCredentials:
            return .post
        }
    }
    
    var needsToken: Bool {
        switch self {
        case .login:
            return false
        case .changePassword,
             .verifyPassword,
             .getSigningCredentials:
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
        case .getSigningCredentials(let publicKey):
            return [
                "public_key": publicKey
            ]
        }
    }
}
