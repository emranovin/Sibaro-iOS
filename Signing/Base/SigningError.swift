//
//  SigningError.swift
//  Sibaro
//
//  Created by Emran Novin on 9/29/23.
//

import Foundation

enum SigningError: Error {
    case resign
    case appFolderMissing
    case invalidInfoPlist
}
