//
//  ProductItemView.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI
import NukeUI

struct ProductItemView: View {
    
    var product: Product
    
    private let service = ProductsService()
    
    @State var loading: Bool = false
    
    @EnvironmentObject var account: Account
    @Environment(\.openURL) var openURL
    
    var body: some View {
        HStack {
            LazyImage(url: URL(string: product.icon)) { state in
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
                Text(product.title)
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(product.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            // MARK: - Install button
            ZStack {
                ProgressView()
                    .opacity(loading ? 1 : 0)
                
                Button(action: install) {
                    Text("Install")
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
                .opacity(loading ? 0 : 1)
            }
        }
        #if os(macOS)
        .padding(.vertical, 4)
        #endif
    }
    
    func install() {
        Task {
            withAnimation {
                self.loading = true
            }
            do {
                let manifest = try await service.getManifest(
                    id: product.id,
                    token: account.userToken
                )
                if let manifest {
                    openURL(manifest)
                }
            } catch {
                print(error)
            }
            withAnimation {
                self.loading = false
            }
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
