//
//  String.swift
//  Sibaro
//
//  Created by Emran Novin on 8/15/23.
//

import Foundation

extension String {
    
    /// Compare two string version of the app
    /// - Parameter otherVersion: the version of second app to compare
    /// - Returns: If the first app version is smaller than or same as the second one this will be false otherwise this will be true
    func isBigger(than otherVersion: String) -> Bool {
        let delimiter = "."
        var lhs = self.components(separatedBy: delimiter)
        var rhs = otherVersion.components(separatedBy: delimiter)
        let diff = lhs.count - rhs.count
        let zeros = Array(repeating: "0", count: abs(diff))
        diff > 0 ? rhs.append(contentsOf: zeros) : lhs.append(contentsOf: zeros)
        return (lhs.joined(separator: delimiter).compare(rhs.joined(separator: delimiter), options: .numeric) == .orderedDescending)
    }
}
