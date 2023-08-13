//
//  ProductItemView.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI

struct ProductItemView: View {
    
    var product: Product
    
    private let service = ProductsService()
    
    @State var loading: Bool = false
    @State var showDetails: Bool = false
    
    @EnvironmentObject var account: Account
    @Environment(\.openURL) var openURL
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: product.icon)) { image in
                image.resizable()
            } placeholder: {
                Rectangle()
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack {
                Text(product.title)
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(product.subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
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
                        .fontWeight(.semibold)
                }
                #if os(iOS)
                .buttonBorderShape(.capsule)
                #endif
                .buttonStyle(.borderedProminent)
                .padding()
                .opacity(loading ? 0 : 1)
            }
        }
        .onTapGesture {
            showDetails.toggle()
        }
        .sheet(isPresented: $showDetails) {
            ProductDetailsView(product: product)
                #if os(macOS)
                .frame(minWidth: 350, idealWidth: 600, minHeight: 500, idealHeight: 650)
                #endif
        }
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
        ProductItemView(product: .mock)
    }
}
