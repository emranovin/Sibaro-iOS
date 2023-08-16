//
//  Array.swift
//  Sibaro
//
//  Created by Emran Novin on 8/15/23.
//

#if os(iOS)
import Foundation

extension Dictionary where Key == String, Value == SystemApplication {
    func productVersion(for bundleIdentifier: String) -> String? {
        self[bundleIdentifier]?.version
    }
}
#endif
