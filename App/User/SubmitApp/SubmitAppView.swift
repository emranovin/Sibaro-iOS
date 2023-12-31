//
//  SubmitAppView.swift
//  Sibaro
//
//  Created by Soroush Arasteh on 8/13/23.
//

import SwiftUI

struct SubmitAppView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: ViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: ViewModel())
    }
    
    var body: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            NavigationStack {
                content
                    .formStyle(.grouped)
            }
        } else {
            NavigationView {
                content
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
            }
        }
    }
    
    var content: some View {
        Form {
            Section {
                /// App name
                TextField(
                    "Name",
                    text: $viewModel.appName,
                    prompt: Text("Application name")
                )
                #if os(iOS)
                .keyboardType(.default)
                #endif
                
                /// App Link
                TextField(
                    "Link",
                    text: $viewModel.appLink,
                    prompt: Text("Application Link")
                )
                #if os(iOS)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                #endif
            } header: {
                VStack {
                    SymbolView(
                        icon: "app.badge.checkmark.fill",
                        color: .blue
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init())
                    .padding(.bottom, 20)
                    #if os(macOS)
                    .padding(.top, 20)
                    #endif
                    
                    Text("Request New App")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                }
                .foregroundStyle(.primary)
                .textCase(nil)
                .frame(maxWidth: .infinity)
            }
            
            Section("Description") {
                /// App Description
                TextEditor(text: $viewModel.appDescription)
                    .frame(minHeight: 150)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                ZStack {
                    ProgressView()
                        .opacity(viewModel.loading ? 1 : 0)
                    
                    Button(action: viewModel.submitApp) {
                        Text("Submit")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .opacity(viewModel.loading ? 0 : 1)
                }
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
        }
        .alert(
            viewModel.messageTitle,
            isPresented: $viewModel.showMessage
        ) {
            Button("Ok", role: .cancel) {
                if viewModel.isSent {
                    dismiss()
                }
            }
        } message: {
            Text(viewModel.messageSubtitle)
        }
    }
}

struct SubmitAppView_Previews: PreviewProvider {
    static var previews: some View {
        SubmitAppView()
    }
}
