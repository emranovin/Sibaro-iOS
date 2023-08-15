//
//  SibaroJSONDecoder.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/23/1402 AP.
//

import Foundation

class SibaroJSONDecoder: JSONDecoder {
    override init() {
        super.init()
        
        keyDecodingStrategy = .convertFromSnakeCase
        dateDecodingStrategy = .custom(dateDecoder)
    }
    
    func dateDecoder(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        guard let date = Date(from: dateString) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        return date
    }
}
