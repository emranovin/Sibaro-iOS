//
//  DesiredAppService.swift
//  Sibaro
//
//  Created by Soroush Arasteh on 8/14/23.
//

import Foundation

protocol DesiredAppServiceProtocolo {
    func appSuggestion(
        token: String,
        name: String,
        link: String?,
        description: String?
    ) async throws -> DesiredApp
}

struct DesiredAppService: HTTPClient, DesiredAppServiceProtocolo {
    func appSuggestion(token: String, name: String, link: String?, description: String?) async throws -> DesiredApp {
        return try await sendRequest(
            endpoint: DesiredAppEndpoint.appSuggestion(token: token, name: name, link: link, description: description),
            responseModel: DesiredApp.self)
    }
}
