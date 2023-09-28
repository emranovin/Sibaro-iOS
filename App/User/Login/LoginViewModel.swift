//
//  LoginViewModel.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/25/1402 AP.
//

import Foundation
import Combine

extension LoginView {
    @MainActor
    class ViewModel: BaseViewModel {
        @Injected(\.authRepository) var auth
        @Injected(\.storage) var storage
        
        @Published var username: String = ""
        @Published var password: String = ""
        
        @Published var loading: Bool = false
        @Published var message: String = ""
        
        private func _login() async {
            loading = true
            do {
                let response = try await auth.login(username: username, password: password)
                storage.token = response.access
                storage.username = username
                loading = false
            } catch {
                print(error)
                loading = false
                guard let error = error as? RequestError else {
                    return
                }
                switch error {
                case .unauthorized(let data):
                    let decodedResponse = try? JSONDecoder().decode(LoginMessage.self, from: data)
                    message = decodedResponse?.detail ?? ""
                default:
                    message = error.errorDescription ?? i18n.Global_UnknownError
                }
            }
        }
        
        nonisolated func login() {
            Task {
                await _login()
            }
        }
    }
}
