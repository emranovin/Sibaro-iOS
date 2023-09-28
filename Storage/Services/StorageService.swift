//
//  StorageService.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/23/1402 AP.
//

import Foundation
import Combine

protocol StorageServicable: BaseService {
    var token: String? { get set }
    var username: String? { get set }
    var publicKey: String? { get set }
    var privateKey: String? { get set }
    var p12: Data? { get set }
    var cert: Data? { get set }
    var profile: Data? { get set }
    func logout()
    
    var language: Language { get set }
    var authenticationStateChanged: AnyPublisher<Bool, Never> { get }
}

class StorageService: BaseService, StorageServicable {
    // MARK: - UserInfo
    @Stored(key: "Sibaro.Token", in: .keychain) var token: String? = nil
    @Stored(key: "Sibaro.Username") var username: String? = nil
    var authenticationStateChanged: AnyPublisher<Bool, Never> {
        $token.map{ $0 != nil }.eraseToAnyPublisher()
    }
    
    func logout() {
        token = nil
        username = nil
    }
    
    // MARK: - Language
    @Stored(key: "Sibaro.Language") var language: Language = .en
    
    // MARK: - Signing
    @Stored(key: "Sibaro.PublicKey", in: .keychain) var publicKey: String? = nil
    @Stored(key: "Sibaro.PrivateKey", in: .keychain) var privateKey: String? = nil
    @File(name: "Sibaro.P12", in: .signing) var p12
    @File(name: "Sibaro.Cert", in: .signing) var cert
    @File(name: "Sibaro.Profile", in: .signing) var profile
}
