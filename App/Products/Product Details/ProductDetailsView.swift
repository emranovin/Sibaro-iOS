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
    @Environment(\.dismiss) var dismissAction
    
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
        NavigationStack {
            ScrollView {
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
                    Button {
                        dismissAction()
                    } label: {
                        Label("Close", systemImage: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                    .tint(.secondary)
                }
            }
        }
    }
    
    var appPromotion: some View {
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
                
                Text(viewModel.product.subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // MARK: - Install button
                ZStack(alignment: .leading) {
                    ProgressView()
                        .opacity(viewModel.loading ? 1 : 0)
                    
                    Button(action: proceedApp) {
                        Text(appStateTitle)
                            .font(.body)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 5)
                    }
                    #if os(iOS)
                    .buttonBorderShape(.capsule)
                    #elseif os(macOS)
                    .controlSize(.large)
                    #endif
                    .buttonStyle(.borderedProminent)
                    .opacity(viewModel.loading ? 0 : 1)
                }
            }
            .padding(.trailing, 12)
            .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: 120)
    }
    
    var appDetails: some View {
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
    
    var screenshots: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(viewModel.product.screenshots, id: \.id) { screenshot in
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
            }
            .padding(.horizontal)
        }
    }
    
    var description: some View {
        
        Markdown(viewModel.product.description)
            .multilineTextAlignment(.leading)
            .environment(\.layoutDirection, viewModel.product.description.isRTL ? .rightToLeft : .leftToRight)
            .padding()
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

struct ProductDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailsView(product: .mock)
    }
}
