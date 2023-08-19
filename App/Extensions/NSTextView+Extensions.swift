//
//  NSTextView+Extensions.swift
//  Sibaro
//
//  Created by Armin on 8/17/23.
//

#if os(macOS)
import AppKit

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear
            drawsBackground = true
        }
    }
}
#endif
