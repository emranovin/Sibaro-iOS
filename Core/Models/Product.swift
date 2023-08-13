//
//  Product.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import Foundation

struct Product: Codable {
    let id: Int
    let type: AppType
    let title, subtitle, version, description: String
    let ipaSize: String
    let icon: String
    let bundleIdentifier: String
    let createdAt: String
    let updatedAt: String
    let screenshots: [Screenshot]

    enum CodingKeys: String, CodingKey {
        case id, type, title, subtitle, version, description
        case ipaSize = "ipa_size"
        case icon
        case bundleIdentifier = "bundle_identifier"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case screenshots
    }
}

enum AppType: String, Codable {
    case app = "app"
    case game = "game"
}

struct Screenshot: Codable {
    let image: String
    let width, height: Int
}

struct AppManifest: Codable {
    let manifest: String
    
    var url: URL? {
        URL(string: "itms-services://?action=download-manifest&url=\(manifest)")
    }
}
