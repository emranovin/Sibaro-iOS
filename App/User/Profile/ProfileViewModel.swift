//
//  ProfileViewModel.swift
//  Sibaro
//
//  Created by AminRa on 5/25/1402 AP.
//

import Foundation

extension ProfileView {
    class ViewModel: BaseViewModel {
        @Injected(\.storage) private var storage
        
        @Published var showAppSuggestion: Bool = false
        @Published var showLogoutDialog: Bool = false
        
        var userName: String {
            return storage.username ?? ""
        }
        
        
        private func _logout() async {
            storage.logout()
        }
        
        func logout() {
            Task {
                await _logout()
            }
        }
    }
}
