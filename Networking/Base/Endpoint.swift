//
//  Endpoint.swift
//  Sibaro
//
//  Created by Armin on 2/20/22.
//

import Foundation

struct SibaroAPI {
    static let url: String = "sibaro.mahsa.me"
    static let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.1"
}

public protocol Endpoint {
    var baseURL:    String            { get }
    var path:       String            { get }
    var method:     HTTPMethod        { get }
    var baseHeader: [String: String]  { get }
    var header:     [String: String]? { get }
    var urlParams:  [URLQueryItem]?   { get }
    var body:       [String: Any]?    { get }
    var needsToken: Bool              { get }
}

extension Endpoint {
    var baseURL: String {
        return "https://api.\(SibaroAPI.url)"
    }
    
    var baseHeader: [String: String] {
        return ["X-Application-Version": SibaroAPI.appVersion]
    }
}
