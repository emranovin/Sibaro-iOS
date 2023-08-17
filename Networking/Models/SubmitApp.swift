//
//  SubmitApp.swift
//  Sibaro
//
//  Created by Soroush Arasteh on 8/14/23.
//

import Foundation

struct SubmitApp: Codable {
    let name: String
    let link: String?
    let description: String?
}

struct SubmitAppError: Codable {
    let link: [String]
}
