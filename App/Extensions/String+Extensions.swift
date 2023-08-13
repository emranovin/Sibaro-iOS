//
//  String+Extensions.swift
//  Sibaro
//
//  Created by Armin on 8/14/23.
//

import Foundation

extension String {
    var isRTL: Bool {
        let lang = CFStringTokenizerCopyBestStringLanguage(
            self as CFString,
            CFRange(location: 0, length: self.count)
        )

        if let lang {
            let direction = NSLocale.characterDirection(forLanguage: lang as String)
            return direction == .rightToLeft
        }
        
        return false
    }
}

