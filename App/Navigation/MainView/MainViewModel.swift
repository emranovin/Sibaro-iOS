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
        
        override init() {
            super.init()
        }
        
        var isAuthenticated: Bool {
            storage.token != nil
        }
        
    }
}
