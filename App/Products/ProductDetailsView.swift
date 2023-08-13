//
//  ProductDetailsView.swift
//  Sibaro
//
//  Created by Armin on 8/14/23.
//

import SwiftUI

struct ProductDetailsView: View {
    
    var product: Product
    
    private let service = ProductsService()
    
    @State var loading: Bool = false
    
    @EnvironmentObject var account: Account
    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Label("Close", systemImage: "xmark.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                }
        }
    }
    
    var content: some View {
        ScrollView {
            VStack {
                appPromotion
                
                Divider()
                    .padding(.horizontal)
                
                appDetails
                    .padding()
                
                screenshots
                
                Text(product.description)
                    .multilineTextAlignment(product.description.isRTL ? .trailing : .leading)
                    .frame(
                        maxWidth: .infinity,
                        alignment: product.description.isRTL ? .trailing : .leading
                    )
                    .padding()
            }
        }
    }
    
    var appPromotion: some View {
        HStack {
            AsyncImage(url: URL(string: product.icon)) { image in
                image.resizable()
            } placeholder: {
                Rectangle()
            }
            .frame(width: 96, height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding()
            
            VStack(alignment: .leading) {
                Text(product.title)
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(product.subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // MARK: - Install button
                ZStack(alignment: .leading) {
                    ProgressView()
                        .opacity(loading ? 1 : 0)
                    
                    Button(action: install) {
                        Text("Install")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    #if os(iOS)
                    .buttonBorderShape(.capsule)
                    #elseif os(macOS)
                    .controlSize(.large)
                    #endif
                    .buttonStyle(.borderedProminent)
                    .opacity(loading ? 0 : 1)
                }
            }
        }
    }
    
    var appDetails: some View {
        HStack(spacing: 15) {
            VStack {
                Text("Size")
                    .font(.caption)
                    .fontWeight(.light)
                    
                Text(product.ipaSize)
                    .font(.title3)
                    .fontWeight(.medium)
            }
            
            Divider()
            
            VStack {
                Text("Version")
                    .font(.caption)
                    .fontWeight(.light)
                
                Text(product.version)
                    .font(.title3)
                    .fontWeight(.medium)
            }
        }
        .foregroundStyle(.secondary)
    }
    
    var screenshots: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(product.screenshots, id: \.id) { screenshot in
                    AsyncImage(url: screenshot.url) { image in
                        image.resizable()
                    } placeholder: {
                        Rectangle()
                    }
                    .aspectRatio(screenshot.aspectRatio, contentMode: .fill)
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
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

struct ProductDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailsView(product: .mock)
    }
}
