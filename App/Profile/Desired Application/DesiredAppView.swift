//
//  DesiredAppView.swift
//  Sibaro
//
//  Created by Soroush Arasteh on 8/13/23.
//

import SwiftUI

struct DesiredAppView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel = DesiredAppViewModel()
    
    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    FormTextFieldView(title: "Application Name", value: $viewModel.appName)
                    FormTextFieldView(title: "Link", value: $viewModel.appLink)
                    FormTextFieldView(title: "Description", value: $viewModel.appDescription)
                            .frame(height: 150)
                            
                }
                .padding()

                ZStack {
                    ProgressView()
                        .opacity(viewModel.isLoading ? 1 : 0)
                    
                    Button {
                        Task {
                            if try await viewModel.requestDesiredApp() {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Submit")
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(width: 250)
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical)
                    .opacity(viewModel.isLoading ? 0 : 1)
                }
            }
            .navigationTitle("Desired App")
    }
}

struct DesiredAppView_Previews: PreviewProvider {
    static var previews: some View {
        DesiredAppView()
    }
}
