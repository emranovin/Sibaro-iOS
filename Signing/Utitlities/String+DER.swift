//
//  String+DER.swift
//  Sibaro
//
//  Created by Emran Novin on 9/27/23.
//

import Foundation

extension String {
    
    var der: Data? {
        guard self.contains("-----BEGIN PUBLIC KEY-----") && self.contains("-----END PUBLIC KEY-----") else {
            return nil
        }
        let derKey = self
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return Data(base64Encoded: derKey)
    }
}
