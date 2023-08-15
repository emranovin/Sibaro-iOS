//
//  Array.swift
//  Sibaro
//
//  Created by Emran Novin on 8/15/23.
//

import Foundation

extension Dictionary where Key == String, Value == SystemApplication {
    func productVersion(for bundleIdentifier: String) -> String? {
        self[bundleIdentifier]?.version
    }
}
