//
//  ProductsListView.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI

enum SortType: String, CaseIterable {
    case newest = "Newest"
    case oldest = "Oldest"
    case updated = "Updated"
    case alphabetical = "Alphabetical"
}

struct ProductsListView: View {
    
    var type: AppType
    private let service = ProductsService()
    
    @State private var sortType: SortType = .updated
    @State private var rawProducts: [Product] = []
    @State private var search: String = ""
    
    @State var selectedProduct: Product? = nil
    
    /// Status
    @State private var loading: Bool = false
    @State private var message: String = ""
    
    @EnvironmentObject var account: Account
    
    var products: [Product] {
        let typeFilter = rawProducts.filter { product in
            product.type == type
        }
        
        if search.isEmpty {
            switch sortType {
            case .newest:
                return typeFilter.sorted(by: { $0.createdAt > $1.createdAt })
            case .oldest:
                return typeFilter.sorted(by: { $0.createdAt < $1.createdAt })
            case .updated:
                return typeFilter.sorted(by: { $0.updatedAt > $1.updatedAt })
            case .alphabetical:
                return typeFilter.sorted(by: { $0.title < $1.title })
            }
        } else {
            return typeFilter.filter { product in
                product.title.contains(search)
            }
        }
    }
    
    var body: some View {
        List(products, id: \.id) { product in
            ProductItemView(product: product)
                .onTapGesture {
                    selectedProduct = product
                }
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
        .toolbar {
            ToolbarItem {
                #if os(macOS)
                sortPicker
                #elseif os(iOS)
                Menu {
                    sortPicker
                } label: {
                    Label("Sort by", systemImage: "slider.horizontal.3")
                }
                #endif
            }
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailsView(product: product)
                #if os(macOS)
                .frame(minWidth: 350, idealWidth: 600, minHeight: 500, idealHeight: 650)
                #endif
        }
    }
    
    var sortPicker: some View {
        Picker("Sort by", selection: $sortType) {
            ForEach(SortType.allCases, id: \.self) { type in
                Text(type.rawValue)
            }
        }
        #if os(iOS)
        .onChange(of: sortType) { _ in
            HapticFeedback.shared.start(.medium)
        }
        #endif
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
    @ObservedObject static var i18n = I18nService()
    
    static var previews: some View {
        NavigationStack {
            ProductsListView(type: .app)
                .environmentObject(account)
                .environmentObject(i18n)
                .navigationTitle("Apps")
        }
    }
}
