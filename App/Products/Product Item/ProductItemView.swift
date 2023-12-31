//
//  ProductItemView.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import NukeUI
import SwiftUI

struct ProductItemView: View {
    
    @StateObject var viewModel: ViewModel
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    init(product: Product) {
        _viewModel = StateObject(
            wrappedValue: ViewModel(product: product)
        )
    }
    
    var appStateTitle: String {
        switch viewModel.appState {
        case .open:
            return viewModel.i18n.Product_Open
        case .install:
            return viewModel.i18n.Product_Install
        case .update:
            return viewModel.i18n.Product_Update
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                LazyImage(url: URL(string: viewModel.product.icon)) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 1)
                
                VStack {
                    Text(viewModel.product.title)
                        .font(.title3)
                        .fontWeight(.regular)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(viewModel.product.subtitle ?? "")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                // MARK: - proceedApp button
                ZStack {
                    ProgressView()
                        .opacity(viewModel.loading ? 1 : 0)
                    
                    Button(action: proceedApp) {
                        Text(appStateTitle)
                            #if os(macOS)
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color.accentColor)
                            .padding(.vertical, 2)
                            .frame(minWidth: 64)
                            #else
                            .font(.body.weight(.bold))
                            .frame(minWidth: 60)
                            #endif
                    }
                    #if os(iOS)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.mini)
                    #elseif os(macOS)
                    .buttonStyle(.plain)
                    .tint(.white)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(radius: 1)
                    #endif
                    .opacity(viewModel.loading ? 0 : 1)
                }
            }
            #if os(macOS)
            .padding(.vertical, 4)
            #endif
            
            screenshots
            
            Spacer()
            
            Divider()
                .padding(.vertical, 12)
        }
        #if os(iOS)
        .padding(.horizontal, horizontalSizeClass != .compact ? 12 : 0)
        #else
        .padding(.horizontal)
        #endif
    }
    
    var screenshots: some View {
        ZStack {
            if let first = viewModel.product.screenshots.first {
                Group {
                    if first.width >= first.height {
                        ScreenshotLandscapeView(screenshot: first)
                    } else {
                        let filteredScreenshots = viewModel.product.screenshots.prefix(3)
                        ScreenshotPortraitView(screenshots: Array(filteredScreenshots))
                    }
                }
                .padding(.top, 22)
            }
        }
    }
    
    func proceedApp() {
        #if os(iOS)
        HapticFeedback.shared.start(.success)
        #endif
        Task {
            viewModel.handleApplicationAction()
        }
    }
    
}

struct ProductItemView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LazyVStack {
                ProductItemView(product: .mock)
                ProductItemView(product: .mock)
                ProductItemView(product: .mock)
            }
            .padding()
        }
    }
}
