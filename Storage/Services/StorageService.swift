//
//  StorageService.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/23/1402 AP.
//

import Foundation

protocol StorageServicable: BaseService {
    var token: String? { get set }
    var username: String? { get set }
    func logout()
    
    var language: Language { get set }
}

class StorageService: BaseService, StorageServicable {
    // MARK: - UserInfo
    @Published(keychain: "Sibaro.Token") var token: String? = nil
    @Published(key: "Sibaro.Username") var username: String? = nil
    func logout() {
        token = nil
        username = nil
    }
    
    override init() {
        super.init()
        print("hello instance")
        objectWillChange.sink { _ in
            print("HEllo")
        }.store(in: &cancelBag)
    }
    
    // MARK: - Language
    @Published(key: "Sibaro.Language") var language: Language = .en
}
