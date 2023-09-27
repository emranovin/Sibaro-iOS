//
//  MainViewModel.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/25/1402 AP.
//
import Combine

extension MainView {
    class ViewModel: BaseViewModel {
        @Injected(\.storage) var storage
        @Injected(\.signingCredentials) var signingCredentials
        
        override init() {
            super.init()
            if isAuthenticated {
                blah()
            }
        }
        
        var isAuthenticated: Bool {
            storage.token != nil
        }
        
        private func blah() {
            Task {
                do {
                    try await signingCredentials.getCredentials()
                } catch {
                    print(error)
                }
            }
        }
    }
}
