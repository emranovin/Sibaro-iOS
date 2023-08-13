//
//  AuthService.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import Foundation

protocol AuthServiceable {
    func login(
        username: String,
        password: String
    ) async throws -> LoginResult
}

struct AuthService: HTTPClient, AuthServiceable {
    func login(
        username: String,
        password: String
    ) async throws -> LoginResult {
        return try await sendRequest(
            endpoint: AuthEndpoint.login(
                username: username,
                password: password
            ),
            responseModel: LoginResult.self
        )
    }
}
