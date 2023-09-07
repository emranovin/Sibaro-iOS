//
//  Constants.swift
//  Sibaro
//
//  Created by Armin on 9/7/23.
//

import Foundation

struct SFSymbols {
    #if os(iOS)
    static let closeButton: String = "xmark.circle.fill"
    #elseif os(macOS)
    static let closeButton: String = "xmark.circle"
    #else
    static let closeButton: String = "xmark"
    #endif
}
