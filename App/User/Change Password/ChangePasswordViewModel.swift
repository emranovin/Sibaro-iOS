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
        @Published var succesfullyChangedPassword: Bool = false
        
        @Published var loading: Bool = false
        @Published var message: String = "Bad Request"
        @Published var showAlert: Bool = false {
            didSet {
                if !showAlert {
                    message = ""
                }
            }
        }
        
        
        private func _validatePasswords() -> String? {
            if newPassword.isEmpty || currentPassword.isEmpty || confirmPassword.isEmpty {
                return "New password and confirmation are not the same"
            } else if !newPassword.matchs(regex: ".{8}") {
                return "New Passowrd must contain at least 8 characters"
            } else if newPassword != confirmPassword {
                return "New password and confirmation are not the same"
            } else if !newPassword.matchs(regex: ".*[0-9]+.*") {
                return "New password must at least contain one number"
            } else if !newPassword.matchs(regex: ".*[a-z]+.*") {
                return "New password must at least contain one uppercase letter"
            } else if !newPassword.matchs(regex: ".*[A-Z]+.*") {
                return "New password must at least contain one lowecase letter"
            }
            return nil
        }
        
        private func _verifyAndChangePassword() async {
            if let validationMessage = _validatePasswords() {
                message = validationMessage
                showAlert = true
                return
            }
            
            do {
                try await auth.verifyPassword(password: currentPassword)
                try await auth.changePassword(oldPassword: currentPassword, newPassword: newPassword)
                succesfullyChangedPassword = true
            } catch {
                print(error)
                if let error = error as? RequestError {
                    switch error {
                    case .unauthorized(_):
                        message = "Unauthorized"
                    case .badRequest(let data):
                        if let verifyPasswordError = try? SibaroJSONDecoder().decode(VerifyPasswordError.self, from: data) {
                            message = verifyPasswordError.password.joined(separator: "\n")
                        } else if let changePsswordError = try? SibaroJSONDecoder().decode(ChangePasswordError.self, from: data) {
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
                await _verifyAndChangePassword()
            }
        }
    }
}
