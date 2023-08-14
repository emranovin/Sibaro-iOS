//
//  DesiredAppViewModel.swift
//  Sibaro
//
//  Created by Soroush Arasteh on 8/14/23.
//

import Foundation
import SimpleKeychain

enum TextFieldErrors: Error {
    case isEmpty(message: String)
}

class DesiredAppViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var appName: String = ""
    @Published var appLink: String = ""
    @Published var appDescription: String = ""
    
    private var userToken: String = ""
    private let desiredAppService = DesiredAppService()
    private let simpleKeychain = SimpleKeychain()
    
    init() {
        let token = try? simpleKeychain.string(forKey: "token")
        if let token {
            DispatchQueue.main.async {
                self.userToken = "Bearer \(token)"
            }
        }
    }
    
    func requestDesiredApp() async throws -> Bool {
        guard !isLoading else { return false }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        guard !appName.isEmpty else {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            throw TextFieldErrors.isEmpty(message: "This Field Is Required")
        }
        
        do {
            let result = try await desiredAppService.appSuggestion(token: userToken, name: appName, link: appLink, description: appDescription)
            print(result)
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return true
        } catch let error {
            print(error.localizedDescription)
            return false
        }
    }
}
