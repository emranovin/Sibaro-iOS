//
//  ProductsListView.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI

struct ProductsListView: View {
    
    var type: AppType
    private let service = ProductsService()
    
    @State private var rawProducts: [Product] = []
    @State private var search: String = ""
    
    /// Status
    @State private var loading: Bool = false
    @State private var message: String = ""
    
    @EnvironmentObject var account: Account
    
    var products: [Product] {
        let typeFilter = rawProducts.filter { product in
            product.type == type
        }
        
        if search.isEmpty {
            return typeFilter
        } else {
            return typeFilter.filter { product in
                product.title.contains(search)
            }
        }
    }
    
    var body: some View {
        List(products, id: \.id) { product in
            ProductItemView(product: product)
        }
        .listStyle(.plain)
        .overlay(emptyState)
        .searchable(text: $search)
        .task {
            loading = true
            await getList()
        }
        .refreshable {
            await getList()
        }
    }
    
    var emptyState: some View {
        ZStack {
            /// Loading Empty state
            if loading && products.isEmpty {
                EmptyStateView(
                    isLoading: true,
                    title: "Updating..."
                )
            }
            
            /// Failed Empty state
            if !loading && products.isEmpty && message != "" {
                EmptyStateView(
                    icon: "wifi.exclamationmark",
                    showAlt: false,
                    title: message,
                    actionTitle: "Try again"
                ) {
                    Task {
                        loading = true
                        await getList()
                    }
                }
            }
        }
    }
    
    func getList() async {
        do {
            rawProducts = try await service.products(token: account.userToken)
        } catch {
            print(error)
            if let error = error as? RequestError {
                switch error {
                case .unauthorized(let data):
                    let decodedResponse = try? JSONDecoder().decode(ProductError.self, from: data)
                    message = decodedResponse?.detail ?? "Failed to get products"
                default:
                    message = error.description
                }
            }
        }
        
        withAnimation {
            self.loading = false
        }
    }
}

struct ProductsListView_Previews: PreviewProvider {
    @StateObject static var account = Account()
    
    static var previews: some View {
        return ProductsListView(type: .app)
            .environmentObject(account)
    }
}
