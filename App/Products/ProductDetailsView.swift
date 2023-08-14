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
    
    var product: Product
    
    private let service = ProductsService()
    
    @State var loading: Bool = false
    
    @EnvironmentObject var account: Account
    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    appPromotion
                        .padding(.bottom, 12)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    appDetails
                        .padding()
                    
                    screenshots
                    
                    description
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
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
            LazyImage(url: URL(string: product.icon)) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                }
            }
            .frame(maxWidth: 120)
            .clipShape(RoundedRectangle(cornerRadius: 27))
            .shadow(radius: 1)
            .padding()
            
            VStack(alignment: .leading) {
                Text(product.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(product.subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // MARK: - Install button
                ZStack(alignment: .leading) {
                    ProgressView()
                        .opacity(loading ? 1 : 0)
                    
                    Button(action: install) {
                        Text("Install")
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
                    .opacity(loading ? 0 : 1)
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
                    
                Text(product.ipaSize)
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
                
                Text(product.version)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    var screenshots: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(product.screenshots, id: \.id) { screenshot in
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
        
        Markdown(product.description)
            .multilineTextAlignment(product.description.isRTL ? .trailing : .leading)
            .padding()
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
