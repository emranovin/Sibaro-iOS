//
//  String+snakeCased.swift
//  Sibaro
//
//  Created by AminRa on 6/2/1402 AP.
//

import Foundation

extension String {
    func asSnakeCase() -> String {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        if let encoded = try? encoder.encode(self), let result = String(data: encoded, encoding: .utf8) {
            return result
        } else {
            return self
        }
    }
}
