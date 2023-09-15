//
//  Product.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import Foundation

struct Product: Codable, Identifiable {
    let id: Int
    let type: AppType
    let title: String
    let subtitle: String?
    let version, description: String
    let ipaSize: String
    let icon: String
    let bundleIdentifier: String
    let createdAt: Date
    let updatedAt: Date
    let screenshots: [Screenshot]
    
    var shareURL: URL {
        URL(string: "https://\(SibaroAPI.url)/tabs/item/\(id)")!
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
        createdAt: Date(from: "2023-08-13T13:04:58.442039Z")!,
        updatedAt: Date(from: "2023-08-13T13:04:58.447161Z")!,
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
    
    static func dummy() -> Product {
        return Product(
            id: UUID().hashValue,
            type: .app,
            title: String(repeating: "-", count: 5),
            subtitle: String(repeating: "-", count: 8),
            version: String(repeating: "-", count: 8),
            description: String(repeating: "-", count: 42),
            ipaSize: String(repeating: "-", count: 3),
            icon: "",
            bundleIdentifier: "",
            createdAt: .now,
            updatedAt: .now,
            screenshots: [
                .init(image: "", width: 392, height: 696),
                .init(image: "", width: 392, height: 696),
                .init(image: "", width: 392, height: 696),
                .init(image: "", width: 392, height: 696),
            ]
        )
    }
}

extension Product: Equatable {
    static func ==(lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
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
    
    static var mocks: [Screenshot] {
        return [
            .init(
                image: "https://api.sibaro.mahsa.me/media/screenshots/09b288d5-1c60-4c9f-bfcb-67933cd53de1.jpeg",
                width: 1080,
                height: 2152
            ),
            .init(
                image: "https://api.sibaro.mahsa.me/media/screenshots/d1170849-ee9d-4002-8f2b-099c4ea63fe7.jpeg",
                width: 1080,
                height: 1990
            ),
            .init(
                image: "https://api.sibaro.mahsa.me/media/screenshots/96480465-2ce0-46f4-936b-b427f5d1e4d3.jpeg",
                width: 1080,
                height: 2157
            ),
        ]
    }
}

struct AppManifest: Codable {
    let manifest: String
    
    var url: URL? {
        URL(string: "itms-services://?action=download-manifest&url=\(manifest)")
    }
}

enum InstallationState: String, Codable {
    case open
    case install
    case update
}
