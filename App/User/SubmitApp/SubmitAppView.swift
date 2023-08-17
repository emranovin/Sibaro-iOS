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
            ScrollView {
                VStack(spacing: 20) {
                    FormTextFieldView(title: "Application Name", value: $viewModel.appName)
                    FormTextFieldView(title: "Link", value: $viewModel.appLink)
                    FormTextFieldView(title: "Description", value: $viewModel.appDescription)
                            .frame(height: 150)
                }
                .padding()

                if let status = viewModel.status {
                    StatusToast(status: status)
                        .transition(.opacity)
                }
                
                ZStack {
                    ProgressView()
                        .opacity(viewModel.loading ? 1 : 0)
                    
                    Button(action: viewModel.submitApp) {
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
                    .opacity(viewModel.loading ? 0 : 1)
                }
            }
            .navigationTitle("Desired App")
    }
}

struct StatusToast: View {
    
    var status: SubmitStatus
    
    var body: some View {
        Group {
            switch status {
            case .success(let message):
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green.gradient)
                    
                    Text(message)
                        .font(.callout)
                }
            case .failed(let message):
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red.gradient)
                    
                    Text(message)
                        .font(.callout)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(Capsule())
        .shadow(radius: 2)
    }
}

struct SubmitAppView_Previews: PreviewProvider {
    static var previews: some View {
        SubmitAppView()
    }
}
