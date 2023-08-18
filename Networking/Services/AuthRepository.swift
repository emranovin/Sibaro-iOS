//
//  AuthService.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import Foundation

protocol AuthRepositoryType: BaseService {
    func login(
        username: String,
        password: String
    ) async throws -> LoginResult
    
    func changePassword(
        oldPassword: String,
        newPassword: String
    ) async throws -> ChangePasswordResult
}

class AuthRepository: BaseService, HTTPClient, AuthRepositoryType {
    @Injected(\.storage) var storage
    
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
    
    func changePassword(
        oldPassword: String,
        newPassword: String
    ) async throws -> ChangePasswordResult {
        return try await sendRequest(
            endpoint: AuthEndpoint.changePassword(
                oldPassword: oldPassword,
                newPassword: newPassword
            ),
            responseModel: ChangePasswordResult.self
        )
    }
    
}
