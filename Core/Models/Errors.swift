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

    enum CodingKeys: String, CodingKey {
        case tokenClass = "token_class"
        case tokenType = "token_type"
        case message
    }
}
