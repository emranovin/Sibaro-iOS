//
//  URL+CreateDirectory.swift
//  Sibaro
//
//  Created by Emran Novin on 9/29/23.
//

import Foundation

extension URL {
    func creatingDirectories() -> URL {
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(
                atPath: path,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        return self
    }
}
