//
//  DesiredAppViewModel.swift
//  Sibaro
//
//  Created by Soroush Arasteh on 8/14/23.
//

import Foundation

extension SubmitAppView {
    @MainActor
    class ViewModel: BaseViewModel {
        @Injected(\.submitAppRepository) var submitAppRepository
        @Injected(\.storage) var storage
        
        @Published var appName: String = ""
        @Published var appLink: String = ""
        @Published var appDescription: String = ""
        
        /// Status
        @Published var loading: Bool = false
        @Published var status: SubmitStatus? = nil
        
        func _submitApp() async {
            loading = true
            do {
                let _ = try await submitAppRepository.appSuggestion(
                    name: appName,
                    link: appLink,
                    description: appDescription
                )
                
                status = .success(message: "Submitted")
                
            } catch {
                if let error = error as? RequestError {
                    switch error {
                    case .badRequest(let data):
                        let decodedResponse = try? JSONDecoder().decode(SubmitAppError.self, from: data)
                        status = .failed(message: decodedResponse?.link.first ?? "Failed to submit, try again")
                    default:
                        status = .failed(message: error.description)
                    }
                } else {
                    status = .failed(message: "Failed to submit, try again")
                }
            }
            loading = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.status = nil
            }
        }
        
        nonisolated func submitApp() {
            Task {
                await _submitApp()
            }
        }
    }
}

enum SubmitStatus: Equatable {
    case success(message: String)
    case failed(message: String)
}
