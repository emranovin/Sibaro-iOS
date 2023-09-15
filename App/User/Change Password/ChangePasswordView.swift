//
//  ChangePasswordView.swift
//  Sibaro
//
//  Created by AminRa on 5/26/1402 AP.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var currentPassword: String = ""
    @State var newPassword: String = ""
    @State var confirmPassword: String = ""
    
    @StateObject var viewModel: ViewModel = ViewModel()
    
    @FocusState private var focusedField: FocuseState?
    
    private enum FocuseState: Hashable {
        case currentPassword, newPassword, confirmPassword
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    currentPassField
                } header: {
                    VStack {
                        Image(systemName: "key.fill")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(.init())
                            .background(in: Circle().inset(by: -20))
                            .backgroundStyle(.orange.gradient)
                            .foregroundStyle(.white)
                            .padding(.bottom, 20)
                            #if os(macOS)
                            .padding(.top, 20)
                            #endif
                        
                        Text("Change Password")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom, 10)
                    }
                    .foregroundStyle(.primary)
                    .textCase(nil)
                    .frame(maxWidth: .infinity)
                }
                
                Section {
                    newPassField
                    newPassConfirmField
                } header: {
                    Text("New Password")
                } footer: {
                    Text("New password must contain at least 8 characters including uppder and lowercase letters and and at least one number")
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    submitButton
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {dismiss()}) {
                        Text("Cancel")
                    }
                }
            }
            .alert(viewModel.alertStatus?.title ?? "", isPresented: $viewModel.showAlert) {
                Button("Ok", role: .cancel) {
                    if viewModel.alertStatus == .success {
                        dismiss()
                    }
                }
            } message: {
                Text(viewModel.alertStatus?.message ?? "")
                    .font(.callout)
                    .tint(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
            }
            .formStyle(.grouped)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
    
    var currentPassField: some View {
        SecureField("Current Password", text: $currentPassword, prompt: Text("Enter current password"))
            .textContentType(.password)
            .focused($focusedField, equals: .currentPassword)
            .privacySensitive(true)
            .disabled(viewModel.loading)
            .onSubmit {
                focusedField = .newPassword
            }
    }
    
    var newPassField: some View {
        SecureField("New", text: $newPassword, prompt: Text("Enter new password"))
            #if os(iOS)
            .textContentType(.newPassword)
            #endif
            .focused($focusedField, equals: .newPassword)
            .privacySensitive(true)
            .disabled(viewModel.loading)
            .onSubmit {
                focusedField = .confirmPassword
            }
    }
    
    var newPassConfirmField: some View {
        SecureField("Verify", text: $confirmPassword, prompt: Text("Re-enter password"))
            #if os(iOS)
            .textContentType(.newPassword)
            #endif
            .focused($focusedField, equals: .confirmPassword)
            .privacySensitive(true)
            .disabled(viewModel.loading)
            .onSubmit(submit)
    }
    
    // MARK: - Change Password button
    var submitButton: some View {
        ZStack {
            ProgressView()
                .opacity(viewModel.loading ? 1 : 0)
            
            Button("Submit", action: submit)
                .opacity(viewModel.loading ? 0 : 1)
        }
    }
}

extension ChangePasswordView {
    func submit() {
        Task {
            await viewModel.verifyAndChangePassword(
                currentPassword: currentPassword,
                newPassword: newPassword,
                confirmPassword: confirmPassword
            )
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChangePasswordView()
        }
    }
}
