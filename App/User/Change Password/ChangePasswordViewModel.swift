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
        
        @Published var currentPassword: String = ""
        @Published var newPassword: String = ""
        @Published var confirmPassword: String = ""
        
        @Published var loading: Bool = false
        @Published var message: String = ""
        
        nonisolated func changePassword() {
            
        }
    }
    
}
