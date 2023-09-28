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
        
        var state: MainView.State {
            if !isAuthenticated {
                return .login
            }
            switch signingCredentials.state {
            case .loading:
                return .loading
            case .loaded:
                return .main
            case .error(let error):
                return .error(error)
            }
        }
        
        override init() {
            super.init()
            storage.authenticationStateChanged.sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.loadSigningCredentials()
                }
            }.store(in: &cancelBag)
        }
        
        var isAuthenticated: Bool {
            storage.token != nil
        }
        
        private func loadSigningCredentials() {
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

extension MainView {
    enum State {
        case main
        case loading
        case error(Error)
        case login
    }
}
