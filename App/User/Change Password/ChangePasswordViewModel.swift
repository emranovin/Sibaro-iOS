//
//  ChangePasswordViewModel.swift
//  Sibaro
//
//  Created by AminRa on 5/26/1402 AP.
//

import Foundation

extension ChangePasswordView {
    
    @MainActor
    class ViewModel: BaseViewModel {
        
        @Injected(\.authRepository) var auth
        
        @Published var currentPassword: String = ""
        @Published var newPassword: String = ""
        @Published var confirmPassword: String = ""
        
        @Published var loading: Bool = false
        @Published var message: String = "Bad Request"
        @Published var showAlert: Bool = false {
            didSet {
                if !showAlert {
                    message = ""
                }
            }
        }
        
        private func _changePassword() async {
            do {
                let results = try await auth.changePassword(oldPassword: currentPassword, newPassword: newPassword)
            } catch {
                print(error)
                if let error = error as? RequestError {
                    switch error {
                    case .unauthorized(_):
                        message = "Unauthorized"
                    case .badRequest(let data):
                        if let changePsswordError = try? SibaroJSONDecoder().decode(ChangePasswordError.self, from: data) {
                            message = (
                                (changePsswordError.newPassword?.joined(separator: "\n") ?? "")
                                +
                                ( "\n" + (changePsswordError.oldPassword?.joined(separator: "\n") ?? "")))
                        }
                    default:
                        message = error.description
                    }
                    showAlert = true
                }
            }
            loading = false
        }
        
        nonisolated func changePassword() {
            Task {
                await _changePassword()
            }
        }
    }
    
}
