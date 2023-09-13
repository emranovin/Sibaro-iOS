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
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $viewModel.appName, prompt: Text("Application name"))
                    TextField("Link", text: $viewModel.appLink, prompt: Text("Application Link"))
                } header: {
                    VStack {
                        Image(systemName: "app.badge.checkmark.fill")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(.init())
                            .background(in: .circle.inset(by: -20))
                            .backgroundStyle(.blue.gradient)
                            .foregroundStyle(.white)
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
                    TextEditor(text: $viewModel.appDescription)
                        .frame(minHeight: 150)
                }
            }
            .formStyle(.grouped)
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
                Button("Ok", role: .cancel) {}
            } message: {
                Text(viewModel.messageSubtitle)
            }
        }
    }
}

struct SubmitAppView_Previews: PreviewProvider {
    static var previews: some View {
        SubmitAppView()
    }
}
