//
//  SubmitAppRepository.swift
//  Sibaro
//
//  Created by Soroush Arasteh on 8/14/23.
//

import Foundation

protocol SubmitAppRepositoryType {
    func appSuggestion(
        name: String,
        link: String?,
        description: String?
    ) async throws -> SubmitApp
}

class SubmitAppRepository: BaseService, HTTPClient, SubmitAppRepositoryType {
    @Injected(\.storage) var storage
    
    func appSuggestion(
        name: String,
        link: String?,
        description: String?
    ) async throws -> SubmitApp {
        return try await sendRequest(
            endpoint: SubmitAppEndpoint.appSuggestion(
                name: name,
                link: link,
                description: description
            ),
            responseModel: SubmitApp.self
        )
    }
}
