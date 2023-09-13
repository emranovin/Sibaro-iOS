//
//  ProductDetailsView.swift
//  Sibaro
//
//  Created by Armin on 8/14/23.
//

import NukeUI
import SwiftUI
import MarkdownUI

struct ProductDetailsView: View {
    
    @StateObject var viewModel: ViewModel
    @State private var scrollOffset: CGFloat = .zero

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    private var hasScrolledAppPromotion: Bool {
        scrollOffset > 135
    }

    init(product: Product) {
        self._viewModel = StateObject(wrappedValue: ViewModel(product: product))
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
        ObservableScrollView(scrollOffset: $scrollOffset) { _ in
            VStack {
                appPromotion
                    .padding(.bottom, 12)
                    #if os(macOS)
                    .padding(.top, 24)
                    #endif
                
                Divider()
                    .padding(.horizontal)
                
                appDetails
                    .padding()
                
                screenshots
                
                description
            }
        }
        .toolbar {
            ToolbarItem {
                navBarButton
            }
            
            ToolbarItem {
                #if os(iOS)
                if horizontalSizeClass != .compact {
                    shareButton
                }
                #else
                shareButton
                #endif
            }
        }
        .navigationTitle(hasScrolledAppPromotion ? viewModel.product.title : "")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var appPromotion: some View {
        HStack {
            LazyImage(url: URL(string: viewModel.product.icon)) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .frame(width: 120, height: 120)
                }
            }
            .frame(maxWidth: 120, maxHeight: 120)
            .clipShape(RoundedRectangle(cornerRadius: 27))
            .shadow(radius: 1)
            .padding()
            
            VStack(alignment: .leading) {
                Text(viewModel.product.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(viewModel.product.subtitle ?? "")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                HStack {
                    // MARK: - Install button
                    installButton
                    
                    Spacer()
                    
                    // MARK: - Share button
                    #if os(iOS)
                    if horizontalSizeClass == .compact {
                        shareButton
                            .labelStyle(.iconOnly)
                            .padding(.horizontal)
                    }
                    #endif
                }
            }
            .padding(.trailing, 12)
            .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: 120)
    }

    private var installButton: some View {
        ZStack(alignment: .center) {
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
                    .frame(minWidth: 60)
                    .font(.body.weight(.semibold))
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
            #endif
            .opacity(viewModel.loading ? 0 : 1)
        }
    }
    
    private var shareButton: some View {
        Group {
            if #available(iOS 16.0, macOS 13.0, *) {
                ShareLink(
                    item: viewModel.product.shareURL,
                    preview: .init(viewModel.product.title)
                )
            } else {
                Spacer()
            }
        }
    }
    
    private var appDetails: some View {
        HStack(spacing: 15) {
            VStack {
                Text("Size")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .textCase(.uppercase)
                    .foregroundStyle(.tertiary)
                    
                Text(viewModel.product.ipaSize)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            VStack {
                Text("Version")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .textCase(.uppercase)
                    .foregroundStyle(.tertiary)
                
                Text(viewModel.product.version)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var screenshots: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(viewModel.product.screenshots, id: \.id) { screenshot in
                    Button {
                        viewModel.previewURL = screenshot.url
                        #if os(macOS)
                        ScreenshotView(imageAddress: viewModel.previewURL)
                            .frame(minWidth: 512, minHeight: 512)
                            .openInWindow(
                                title: viewModel.product.title,
                                sender: self,
                                transparentTitlebar: true
                            )
                        #else
                        viewModel.showPreview.toggle()
                        #endif
                        
                    } label: {
                        LazyImage(url: screenshot.url) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                            } else {
                                Rectangle()
                            }
                        }
                        .aspectRatio(screenshot.aspectRatio, contentMode: .fill)
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            #if os(iOS)
            .fullScreenCover(isPresented: $viewModel.showPreview) {
                ScreenshotView(imageAddress: viewModel.previewURL)
            }
            #endif
        }
    }

    private var description: some View {
        Markdown(viewModel.product.description)
            .multilineTextAlignment(.leading)
            .environment(\.layoutDirection, viewModel.product.description.isRTL ? .rightToLeft : .leftToRight)
            .padding()
    }

    @ViewBuilder private var navBarButton: some View {
        if hasScrolledAppPromotion {
            installButton
        } else {
            EmptyView()
        }
    }

    private func proceedApp() {
        #if os(iOS)
        HapticFeedback.shared.start(.success)
        #endif
        Task {
            viewModel.handleApplicationAction()
        }
    }
    
}

struct ProductDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailsView(product: .mock)
    }
}
