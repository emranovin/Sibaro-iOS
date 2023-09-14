//
//  ScreenshotPortraitView.swift
//  Sibaro
//
//  Created by Armin on 9/14/23.
//

import NukeUI
import SwiftUI

struct ScreenshotPortraitView: View {
    
    var screenshots: [Screenshot]
    
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            ForEach(screenshots, id: \.id) { screenshot in
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
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .shadow(radius: 1)
            }
            
            /// Empty space for products that their screenshots are less than 3
            if screenshots.count < 3, let ratio = screenshots.first?.aspectRatio {
                ForEach(0..<(3 - screenshots.count), id: \.self) { _ in
                    Rectangle()
                        .fill(.clear)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(ratio, contentMode: .fit)
                }
            }
        }
    }
}

struct ScreenshotPortraitView_Previews: PreviewProvider {
    static var screenshots: [Screenshot] = Product.mock.screenshots
    
    static var previews: some View {
        ScreenshotPortraitView(screenshots: screenshots)
            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
    }
}
