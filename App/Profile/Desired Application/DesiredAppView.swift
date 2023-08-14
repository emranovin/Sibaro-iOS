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
                
                Button {
                    Task {
                        if try await viewModel.requestDesiredApp() {
                            dismiss()
                        }
                    }
                } label: {
                    Text(viewModel.isLoading ? "" : "Submit")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 45)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                        }
                        .overlay(
                            ProgressView()
                                .foregroundColor(Color.white)
                                .opacity(viewModel.isLoading ? 1 : 0)
                        )
                }

            }
            .navigationBarTitle("Desired App")
    }
}

struct DesiredAppView_Previews: PreviewProvider {
    static var previews: some View {
        DesiredAppView()
    }
}
