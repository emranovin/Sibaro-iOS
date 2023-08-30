//
//  Errors.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import Foundation

struct LoginMessage: Codable {
    let detail: String
}

struct ProductError: Codable {
    let detail, code: String
    let messages: [Message]
}

struct Message: Codable {
    let tokenClass, tokenType, message: String
}

struct ChangePasswordError: Codable {
    let oldPassword: [String]?
    let newPassword: [String]?
}

struct VerifyPasswordError: Codable {
    let password: [String]
}
