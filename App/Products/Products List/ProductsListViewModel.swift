//
//  ProductsListViewModel.swift
//  Sibaro
//
//  Created by AminRa on 5/25/1402 AP.
//

import Foundation
import DependencyFactory

extension ProductsListView {
    @MainActor
    class ViewModel: BaseViewModel {
        @Injected(\.productRepository) var productRepository
        @Injected(\.storage) var storage
        
        var type: AppType
        
        @Published var sortType: SortType = .updated
        @Published var dummyProducts: [Product] = [.dummy(), .dummy(), .dummy(), .dummy()]
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
                    product.title.localizedCaseInsensitiveContains(search)
                }
            }
        }
        
        func getList() async {
            loading = true
            do {
                message = ""
                rawProducts = try await productRepository.products()
            } catch {
                #if DEBUG
                print(error)
                #endif
                if let error = error as? RequestError {
                    switch error {
                    case .unauthorized(let data):
                        let decodedResponse = try? JSONDecoder().decode(ProductError.self, from: data)
                        message = decodedResponse?.detail ?? "Failed to get products"
                    default:
                        message = error.errorDescription ?? i18n.Global_UnknownError
                    }
                } else {
                    message = error.localizedDescription
                }
            }
            loading = false
        }
    }
}
