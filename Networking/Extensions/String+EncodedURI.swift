//
//  String+EncodedURI.swift
//  Sibaro
//
//  Created by Emran Novin on 9/29/23.
//

import Foundation

extension String {
    var encodedURIComponents: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            .replacingOccurrences(of: "&", with: "%26")
            .replacingOccurrences(of: ":", with: "%3A")
            .replacingOccurrences(of: "/", with: "%2F")
            .replacingOccurrences(of: "=", with: "%3D")
    }
}
