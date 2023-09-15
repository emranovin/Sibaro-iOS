//
//  ScreenshotLandscapeView.swift
//  Sibaro
//
//  Created by Armin on 9/14/23.
//

import NukeUI
import SwiftUI

struct ScreenshotLandscapeView: View {
    
    var screenshot: Screenshot
    
    var body: some View {
        LazyImage(url: URL(string: screenshot.image)) { state in
            if let image = state.image {
                image
                    .resizable()
            } else {
                Rectangle()
                    .foregroundStyle(.secondary)
            }
        }
        .aspectRatio(screenshot.aspectRatio, contentMode: .fit)
        .cornerRadius(5)
        .shadow(radius: 1)
        .frame(maxWidth: .infinity)
    }
}

struct ScreenshotLandscapeView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenshotLandscapeView(screenshot: Product.mock.screenshots.first!)
    }
}
