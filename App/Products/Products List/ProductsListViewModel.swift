//
//  ProductsListViewModel.swift
//  Sibaro
//
//  Created by AminRa on 5/25/1402 AP.
//

import Foundation
import Combine

extension ProductsListView {
    @MainActor
    class ViewModel: BaseViewModel {
        @Injected(\.productRepository) var productRepository
        @Injected(\.storage) var storage
        
        var type: AppType
        
        @Published var sortType: SortType = .updated
        @Published var dummyProducts: [Product] = [.dummy(), .dummy(), .dummy(), .dummy()]
        @Published var rawProducts: [Product] = []
        @Published var searchResults: [Product] = []
        @Published var search: String = "" {
            didSet {
                if search.isEmpty {
                    searchResults = []
                }
            }
        }
        private var nextPageCursor: String = ""
        private var nextSeachCursor: String = ""
        @Published var selectedProduct: Product? = nil
        
        /// Status
        @Published var loading: Bool = false
        @Published var message: String = ""
        
        var subscriptions: Set<AnyCancellable> = []
        
        init(type: AppType) {
            self.type = type
            super.init()
            $sortType.dropFirst().sink { [weak self] _ in
                self?.rawProducts = []
                self?.searchResults = []
                self?.nextPageCursor = ""
                self?.nextSeachCursor = ""
                self?.retryLoadingPage()
            }.store(in: &subscriptions)
        }
        
        var products: [Product] {
            if search.isEmpty {
                return rawProducts
            } else {
                return searchResults
            }
        }
        
        func getList() async {
            loading = true
            do {
                message = ""
                let response = try await productRepository.filterProducts(search: search, ordering: sortType.asProductOrderProperty(), type: type, cursor: search.isEmpty ? nextPageCursor: nextSeachCursor)
                if search.isEmpty {
                    
                    if let nextUrl = response.next, let cursor = URL(string: nextUrl)?.queryDictionary?["cursor"] {
                        self.nextPageCursor = cursor
                        rawProducts.append(contentsOf: response.results)
                    }
                } else {
                    
                    if let nextUrl = response.next, let cursor = URL(string: nextUrl)?.queryDictionary?["cursor"] {
                        self.nextSeachCursor = cursor
                        searchResults.append(contentsOf: response.results)
                    }
                }
                
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
                        message = error.description
                    }
                } else {
                    message = error.localizedDescription
                }
            }
            loading = false
        }
        
        func rowDidAppear(withProduct product: Product) {
            Task {
                if product == self.products.last {
                    await getList()
                }
            }
        }
        
        func retryLoadingPage() {
            Task {
                await getList()
            }
        }
        
        func searchFor(query: String) {
            if !query.isEmpty {
                Task {
                    await getList()
                }
            }
        }
        
    }
    
}

extension String {
    func decodeUrl() -> String? {
        return self.removingPercentEncoding
    }
}
