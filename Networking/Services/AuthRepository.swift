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
    
    @discardableResult func changePassword(
        oldPassword: String,
        newPassword: String
    ) async throws -> ChangePasswordResult
    
    @discardableResult func verifyPassword(
        password: String
    ) async throws -> VerifyPasswordResult
    
    func getSigningCredentials(
        publicKey: String
    ) async throws -> SigningCredentials
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
    
    @discardableResult func changePassword(
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
    
    @discardableResult func verifyPassword(
        password: String
    ) async throws -> VerifyPasswordResult {
        return try await sendRequest(
            endpoint: AuthEndpoint.verifyPassword(
                password: password
            ),
            responseModel: VerifyPasswordResult.self
        )
    }
    
    func getSigningCredentials(
        publicKey: String
    ) async throws -> SigningCredentials {
        return try await sendRequest(
            endpoint: AuthEndpoint.getSigningCredentials(publicKey: publicKey),
            responseModel: SigningCredentials.self
        )
    }
}
