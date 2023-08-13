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
    
    static let mock = Product(
        id: 32,
        type: .app,
        title: "SP Camera",
        subtitle: "مخفی فیلم و عکس بگیرید",
        version: "7.5",
        description: "یک متن به صورت تستی برای جایگزین کردن به عنوان یک تکست که در این جمله میگنجد تا بتونیم تست کنیم. ",
        ipaSize: "24.4 MB",
        icon: "https://api.sibaro.mahsa.me/media/icons/5dca6e32-ec68-4b39-a953-a884f3eb32e8.png",
        bundleIdentifier: "com.rathasou.The-Spy-Camera",
        createdAt: "2023-08-13T13:04:58.442039Z",
        updatedAt: "2023-08-13T13:04:58.447161Z",
        screenshots: [
            .init(
                image: "https://api.sibaro.mahsa.me/media/screenshots/7e598724-2a5f-4a90-989f-68de3466b59b.jpg",
                width: 392,
                height: 696
            ),
            .init(
                image: "https://api.sibaro.mahsa.me/media/screenshots/ee5b8e0b-3982-4132-8d3d-52ddbad55759.jpg",
                width: 392,
                height: 696
            ),
            .init(
                image: "https://api.sibaro.mahsa.me/media/screenshots/f70ac7a3-3309-4a9b-b661-52747ff2e554.jpg",
                width: 392,
                height: 696
            ),
            .init(
                image: "https://api.sibaro.mahsa.me/media/screenshots/9c1a4107-ebb9-4e64-a0ee-1a7cae0015c7.jpg",
                width: 392,
                height: 696
            ),
        ]
    )
}

enum AppType: String, Codable {
    case app = "app"
    case game = "game"
}

struct Screenshot: Codable {
    let image: String
    let width, height: Int
    
    var id: UUID {
        return UUID()
    }
    
    var url: URL? {
        URL(string: image)
    }
    
    var aspectRatio: CGFloat {
        CGFloat(width)/CGFloat(height)
    }
}

struct AppManifest: Codable {
    let manifest: String
    
    var url: URL? {
        URL(string: "itms-services://?action=download-manifest&url=\(manifest)")
    }
}
