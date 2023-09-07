//
//  ProductItemView.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI
import NukeUI

struct ProductItemView: View {
    
    
    @StateObject var viewModel: ViewModel
    
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
                            .font(.body)
                            #if os(macOS)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.accentColor)
                            .padding(.vertical, 2)
                            .frame(minWidth: 64)
                            #else
                            .frame(minWidth: 60)
                            .fontWeight(.bold)
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
        }
    }
    
    @ViewBuilder func single(screenshot: Screenshot) -> some View {
        LazyImage(url: URL(string: screenshot.image)) { state in
            if let image = state.image {
                image
                    .resizable()
                    .cornerRadius(5)
                    .aspectRatio(screenshot.aspectRatio, contentMode: .fit)
                    .frame(maxWidth: .infinity)
            } else {
                Rectangle()
                    .foregroundStyle(.secondary)
                    .cornerRadius(5)
                    .aspectRatio(screenshot.aspectRatio, contentMode: .fit)
                    .frame(maxWidth: .infinity)
            }
        }
        .shadow(radius: 1)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder func multiple(screenshots: ArraySlice<Screenshot>) -> some View {
        let ratio = screenshots[0].aspectRatio
        HStack(spacing: 5) {
            ForEach(screenshots, id: \.image) { screenshot in
                LazyImage(url: URL(string: screenshot.image)) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .frame(maxWidth: .infinity)
                            .aspectRatio(screenshot.aspectRatio, contentMode: .fit)
                    } else {
                        Rectangle()
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(screenshot.aspectRatio, contentMode: .fit)
                    }
                    
                }
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .shadow(radius: 1)
            }
            if screenshots.count < 3 {
                ForEach(0..<(3 - screenshots.count), id: \.self) { _ in
                    Rectangle()
                        .fill(.clear)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(ratio, contentMode: .fit)
                }
            }
        }
    }
    
    var screenshots: some View {
        ZStack {
            if let first = viewModel.product.screenshots.first {
                if first.width >= first.height {
                    single(screenshot: first)
                        .padding(.top, 22)
                } else {
                    multiple(screenshots: viewModel.product.screenshots.prefix(3))
                        .padding(.top, 22)
                }
                
            } else {
                EmptyView()
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
        List {
            ProductItemView(product: .mock)
            ProductItemView(product: .mock)
            ProductItemView(product: .mock)
        }
        .listStyle(.plain)
    }
}
