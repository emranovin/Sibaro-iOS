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
        @Published var messageTitle: String = ""
        @Published var messageSubtitle: String = ""
        @Published var showMessage: Bool = false
        @Published var isSent: Bool = false
        
        func _submitApp() async {
            loading = true
            do {
                let _ = try await submitAppRepository.appSuggestion(
                    name: appName,
                    link: appLink,
                    description: appDescription
                )
                
                messageTitle = "Success"
                messageSubtitle = "Your submition has been sent"
                isSent = true
                #if os(iOS)
                HapticFeedback.shared.start(.success)
                #endif
            } catch {
                if let error = error as? RequestError {
                    switch error {
                    case .badRequest(let data):
                        let decodedResponse = try? JSONDecoder().decode(SubmitAppError.self, from: data)
                        messageTitle = "Failed to submit"
                        messageSubtitle = decodedResponse?.link.first ?? "Try again later"
                    default:
                        messageTitle = "Failed to submit"
                        messageSubtitle = error.description
                    }
                } else {
                    messageTitle = "Failed to submit"
                    messageSubtitle = "Try again later"
                }
                #if os(iOS)
                HapticFeedback.shared.start(.error)
                #endif
            }
            loading = false
            showMessage = true
        }
        
        nonisolated func submitApp() {
            Task {
                await _submitApp()
            }
        }
    }
}
