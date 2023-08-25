//
//  ProductPage.swift
//  Sibaro
//
//  Created by AminRa on 6/2/1402 AP.
//

import Foundation

struct ProductsPage: Codable {
    var next: String?
    var previous: String?
    var results: [Product]
}
