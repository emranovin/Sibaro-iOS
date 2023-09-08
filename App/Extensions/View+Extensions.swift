//
//  View+Extensions.swift
//  Sibaro
//
//  Created by Armin on 9/6/23.
//

#if os(macOS)
import SwiftUI

extension View {
    @discardableResult
    func openInWindow(title: String, sender: Any?, transparentTitlebar: Bool = false) -> NSWindow {
        let controller = NSHostingController(rootView: self)
        let window = NSWindow(contentViewController: controller)
        window.contentViewController = controller
        window.title = title
        window.titlebarAppearsTransparent = transparentTitlebar
        window.titleVisibility = transparentTitlebar ? .hidden : .visible
        window.styleMask.insert(transparentTitlebar ? .fullSizeContentView : .titled)
        window.makeKeyAndOrderFront(sender)
        window.orderFrontRegardless()
        return window
    }
}
#endif
