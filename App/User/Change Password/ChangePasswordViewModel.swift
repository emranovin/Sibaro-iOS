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
        
        @Published var loading: Bool = false
        @Published var alertStatus: SubmitStatus? = nil
        @Published var showAlert: Bool = false
        
        private func validatePasswords(
            currentPassword: String,
            newPassword: String,
            confirmPassword: String
        ) -> String? {
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
        
        func verifyAndChangePassword(
            currentPassword: String,
            newPassword: String,
            confirmPassword: String
        ) async {
            loading = true
            if let validationMessage = validatePasswords(
                currentPassword: currentPassword,
                newPassword: newPassword,
                confirmPassword: confirmPassword
            ) {
                alertStatus = .failed(message: validationMessage)
                showAlert = true
                loading = false
                return
            }
            
            do {
                try await auth.verifyPassword(password: currentPassword)
                try await auth.changePassword(oldPassword: currentPassword, newPassword: newPassword)
                alertStatus = .success
            } catch {
                print(error)
                if let error = error as? RequestError {
                    switch error {
                    case .badRequest(let data):
                        /// Verify error
                        if let verifyPasswordError = try? SibaroJSONDecoder().decode(VerifyPasswordError.self, from: data) {
                            let message = verifyPasswordError.password.joined(separator: "\n")
                            alertStatus = .failed(message: message)
                        /// Change Error
                        } else if let changePsswordError = try? SibaroJSONDecoder().decode(ChangePasswordError.self, from: data) {
                            let message = (
                                (changePsswordError.newPassword?.joined(separator: "\n") ?? "")
                                +
                                ( "\n" + (changePsswordError.oldPassword?.joined(separator: "\n") ?? "")))
                            alertStatus = .failed(message: message)
                        }
                    default:
                        alertStatus = .failed(message: error.description)
                    }
                    
                } else {
                    alertStatus = .failed(message: "Failed to change password, try again")
                }
            }
            showAlert = true
            loading = false
        }
    }
    
    enum SubmitStatus: Equatable {
        case success
        case failed(message: String)
        
        var title: String {
            switch self {
            case .success:
                return "Success"
            case .failed:
                return "Failed to change Password"
            }
        }
        
        var message: String {
            switch self {
            case .success:
                return "Your password changed"
            case .failed(let message):
                return message
            }
        }
    }
}
