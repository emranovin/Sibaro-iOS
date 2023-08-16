//
//  ProductDetailsViewModel.swift
//  Sibaro
//
//  Created by AminRa on 5/25/1402 AP.
//

import Foundation

extension ProductDetailsView {
    @MainActor
    class ViewModel: BaseViewModel {
        @Injected(\.applications) var applications
        @Injected(\.productRepository) var productRepository
        @Injected(\.openURL) var openURL
        
        let product: Product
        
        @Published var loading: Bool = false
        
        var appState: InstallationState {
            applications.getAppState(product)
        }
        
        init(product: Product) {
            self.product = product
        }
        
        private func install() async throws {
            let manifest = try await productRepository.getManifest(
                id: product.id
            )
            if let manifest {
                let _ = openURL(manifest)
            }
        }
        
        private func _handleApplicationAction() async {
            loading = true
            do {
                switch appState {
                case .open :
                    applications.openApplication(product.bundleIdentifier)
                default :
                    try await install()
                }
            } catch {
                print(error)
            }
            loading = false
        }
        
        func handleApplicationAction() {
            Task {
                await _handleApplicationAction()
            }
        }
        
    }
}
