//
//  ProductsListViewModel.swift
//  Sibaro
//
//  Created by AminRa on 5/25/1402 AP.
//

import Foundation

extension ProductsListView {
    @MainActor
    class ViewModel: BaseViewModel {
        @Injected(\.productRepository) var productRepository
        @Injected(\.storage) var storage
        
        var type: AppType
        
        @Published var sortType: SortType = .updated
        @Published var rawProducts: [Product] = []
        @Published var search: String = ""
        
        @Published var selectedProduct: Product? = nil
        
        /// Status
        @Published var loading: Bool = false
        @Published var message: String = ""
        
        init(type: AppType) {
            self.type = type
        }
        
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
        
        func _getList() async {
            do {
                rawProducts = try await productRepository.products()
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
            loading = false
        }
        
        func getList(changeLoadingState: Bool = true) {
            if changeLoadingState {
                loading = true
            }
            
            Task {
                await _getList()
            }
        }
    }
}
