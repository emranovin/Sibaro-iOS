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
        HStack {
            LazyImage(url: URL(string: viewModel.product.icon)) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
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
                
                Text(viewModel.product.subtitle)
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
                        .fontWeight(.bold)
                        .padding(.horizontal, 5)
                }
                #if os(iOS)
                .buttonBorderShape(.capsule)
                #elseif os(macOS)
                .controlSize(.large)
                #endif
                .buttonStyle(.bordered)
                .opacity(viewModel.loading ? 0 : 1)
            }
        }
        #if os(macOS)
        .padding(.vertical, 4)
        #endif
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
