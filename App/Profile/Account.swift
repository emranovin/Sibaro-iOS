//
//  Account.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI
import SimpleKeychain

class Account: ObservableObject {
    
    @Published var userToken: String = ""
    @AppStorage("username") var storageUsername = ""
    
    private let simpleKeychain = SimpleKeychain()
    private let authService = AuthService()
    
    public var isUserLoggedIn: Bool {
        userToken.count > 0
    }
    
    init() {
        /// Get user's token and load profile
        let token = try? simpleKeychain.string(forKey: "token")
        if let token {
            DispatchQueue.main.async {
                self.userToken = "Bearer \(token)"
            }
        }
    }
    
    // MARK: - Set Token
    func setToken(_ token: String) async throws {
        try simpleKeychain.set(token, forKey: "token")
        DispatchQueue.main.async {
            withAnimation {
                self.userToken = "Bearer \(token)"
            }
        }
    }
    
    // MARK: - Login
    func login(
        username: String,
        password: String
    ) async throws {
        let result = try await authService.login(
            username: username,
            password: password
        )
        DispatchQueue.main.async {
            self.storageUsername = username
        }
        try await setToken(result.access)
    }
    
    // MARK: - Logout
    func logout() async throws {
        DispatchQueue.main.async {
            self.userToken = ""
        }
        try simpleKeychain.deleteAll()
    }
}
