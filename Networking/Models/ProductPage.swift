//
//  ProductPage.swift
//  Sibaro
//
//  Created by AminRa on 6/2/1402 AP.
//

import Foundation

struct ProductsPage: Codable {
    let next: String?
    let previous: String?
    let results: [Product]
}
