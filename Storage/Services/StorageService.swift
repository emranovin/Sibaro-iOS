//
//  StorageService.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/23/1402 AP.
//

import Foundation

class StorageService {
    // MARK: - UserInfo
    @Published(keychain: "Sibaro.Token") var token: String? = nil
    @Published(key: "Sibaro.Username") var username: String? = nil
    
    // MARK: - Language
    @Published(key: "Sibaro.Language") var language: Language = .en
}
