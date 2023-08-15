//
//  Array.swift
//  Sibaro
//
//  Created by Emran Novin on 8/15/23.
//

import Foundation

extension Array where Element == SystemApplication {
    func productVersion(for bundleIdentifier: String) -> String? {
        first{$0.bundleID == bundleIdentifier}?.version
    }
}
