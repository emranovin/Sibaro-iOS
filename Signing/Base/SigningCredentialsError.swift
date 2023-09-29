//
//  SigningError.swift
//  Sibaro
//
//  Created by Emran Novin on 9/27/23.
//

import Foundation

enum SigningCredentialsError: Error {
    case generateKeyPair
    case badFormat
}
