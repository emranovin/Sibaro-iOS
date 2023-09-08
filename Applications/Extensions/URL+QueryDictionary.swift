//
//  URL+QueryDictionary.swift
//  Sibaro
//
//  Created by AminRa on 6/9/1402 AP.
//

import Foundation

extension URL {
    var queryDictionary: [String: String]? {
        guard let query = URLComponents(string: self.absoluteString)?.query else { return nil}

        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            guard pair.components(separatedBy: "=").count > 1 else { continue }
            
            let key = pair.components(separatedBy: "=")[0]
            
            let value = Array(
                pair.components(separatedBy:"=")[1...]).map({
                    (String($0) == "" ? "=" : $0)
                        .replacingOccurrences(of: "+", with: " ")
                }).joined(separator: "")
            
            queryStrings[key] = value
        }
        return queryStrings
    }
}
