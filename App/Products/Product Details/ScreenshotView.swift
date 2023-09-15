//
//  ScreenshotView.swift
//  Sibaro
//
//  Created by Armin on 9/6/23.
//

import NukeUI
import SwiftUI

struct ScreenshotView {
    @State var imageAddress: URL?
    @State var scale: CGFloat = 1.0
    
    @Environment(\.dismiss) var dismiss
    
    var magnification: some Gesture {
        if #available(iOS 17.0, macOS 14.0, *) {
            return MagnifyGesture()
                .onChanged{ gesture in
                    self.scale = max(gesture.magnification, 1.0)
                }
        } else {
            return MagnificationGesture()
                .onChanged{ value in
                    self.scale = max(value, 1.0)
                }
        }
    }
}

@MainActor
extension ScreenshotView: View {
    var body: some View {
        ZStack {
            #if os(macOS)
            VisualEffectBlur(
                material: .popover,
                blendingMode: .behindWindow
            )
            #endif
            
            content
            
            #if os(iOS)
            closeButton
            #endif
        }
        #if os(macOS)
        .edgesIgnoringSafeArea(.all)
        #endif
        .preferredColorScheme(.dark)
    }
    
    var content: some View {
        LazyImage(url: imageAddress) { state in
            if state.isLoading {
                if state.progress.total > 0 {
                    ProgressView(value: Float(state.progress.completed / state.progress.total))
                }
            } else if let image = state.image {
                #if os(iOS)
                ImagePreviewerView {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                #else
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                #endif
            } else {
                Image(systemName: "photo")
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .scaleEffect(scale)
        .gesture(magnification)
    }
    
    var closeButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .tint(.gray)
                .symbolRenderingMode(.hierarchical)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding()
    }
}

struct ScreenshotView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenshotView(imageAddress: Product.mock.screenshots.first?.url)
    }
}
