//
//  StorageService.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/23/1402 AP.
//

import Foundation

protocol StorageServicable: ObservableObject {
    var token: String? { get set }
    var username: String? { get set }
    
    var language: Language { get set }
}

class StorageService: StorageServicable {
    // MARK: - UserInfo
    @Published(keychain: "Sibaro.Token") var token: String? = nil
    @Published(key: "Sibaro.Username") var username: String? = nil
    
    // MARK: - Language
    @Published(key: "Sibaro.Language") var language: Language = .en
}
