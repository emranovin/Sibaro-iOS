//
//  HTTPClient.swift
//  Sibaro
//
//  Created by Armin on 2/19/22.
//

import Foundation

protocol HTTPClient {
    var storage: StorageServicable { get set }
    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async throws -> T
}

extension HTTPClient {
    func sendRequest<T: Decodable>(
        endpoint: Endpoint,
        responseModel: T.Type
    ) async throws -> T {
        
        var urlComponents = URLComponents(string: endpoint.baseURL + endpoint.path)
        
        if let urlParams = endpoint.urlParams {
            urlComponents?.queryItems = urlParams
        }
        
        guard let url = urlComponents?.url else {
            throw RequestError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.baseHeader
            .merging(endpoint.header ?? [:], uniquingKeysWith: { (first, _) in first })
            .merging(endpoint.needsToken && storage.token != nil ? [
                "Authorization": "Bearer \(storage.token!)"
            ] : [:], uniquingKeysWith: { (first, _) in first })
        
        if let body = endpoint.body {
            // TODO: Manage this `try` of JSONSerialization error
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                print("Failed to create body block")
            }
        }
        if let queryParameters = endpoint.urlParams {
            if #available(iOS 16.0, *) {
                request.url?.append(queryItems: queryParameters)
            } else {
                if let url = request.url, let urlComponents = NSURLComponents.init(url: url, resolvingAgainstBaseURL: false) {
                    if (urlComponents.queryItems == nil) {
                        urlComponents.queryItems = []
                    }
                    urlComponents.queryItems!.append(contentsOf: queryParameters);
                    request.url = url
                }
            }
        }
        let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
        guard let response = response as? HTTPURLResponse else {
            throw RequestError.noResponse
        }
        switch response.statusCode {
        case 200...299:
            do {
                let decodedResponse = try SibaroJSONDecoder().decode(responseModel, from: data)
                return decodedResponse
            } catch {
                #if DEBUG
                print("💥 Execute error:")
                print(error)
                #endif
                throw RequestError.decode
            }
        case 400:
            throw RequestError.badRequest(data)
        case 401:
            if endpoint.needsToken {
                storage.logout()
            }
            throw RequestError.unauthorized(data)
        default:
            throw RequestError.unexpectedStatusCode(response.statusCode)
        }
    }
}
