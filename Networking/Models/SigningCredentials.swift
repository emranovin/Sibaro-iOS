//
//  SigningCredentials.swift
//  Sibaro
//
//  Created by Emran Novin on 9/27/23.
//

import Foundation

struct SigningCredentials: Decodable {
    let publicKey: String
    let p12: String
    let cert: String
    let profile: String
}
