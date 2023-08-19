//
//  ChangePasswordView.swift
//  Sibaro
//
//  Created by AminRa on 5/26/1402 AP.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismissAction
    
    @StateObject var viewModel: ViewModel = ViewModel()
    
    @FocusState private var focusedField: FocuseState?
    @Binding var changedPassowrd: Bool
    
    private enum FocuseState: Hashable {
        case currentPassword, newPassword, confirmPassword
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                content()
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
            }
            .clipped()
        }
    }
    
    @ViewBuilder func content() -> some View {
        VStack(alignment: .leading) {
            Text("Change Password")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            Divider().frame(maxWidth: .infinity)
            // MARK: - Fields
            VStack(alignment: .leading, spacing: nil) {
                
                Label {
                    // MARK: - Password Field
                    SecureField("Current Password", text: $viewModel.currentPassword)
                        .textContentType(.password)
                        .focused($focusedField, equals: .currentPassword)
                        .privacySensitive(true)
                        .disabled(viewModel.loading)
                        .padding(.horizontal)
                        .onSubmit {
                            focusedField = .newPassword
                        }
                } icon: {
                    Text("Password")
                        .frame(maxWidth: 80, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }.padding(.trailing, 16)
                
                Divider()
                
                Label {
                    // MARK: - Password Field
                    SecureField("New Password", text: $viewModel.newPassword)
                        #if os(iOS)
                        .textContentType(.newPassword)
                        #endif
                        .focused($focusedField, equals: .newPassword)
                        .privacySensitive(true)
                        .disabled(viewModel.loading)
                        .padding(.horizontal)
                        .onSubmit {
                            focusedField = .confirmPassword
                        }
                } icon: {
                    Text("New")
                        .frame(maxWidth: 80, alignment: .leading)
                }.padding(.trailing, 16)
                
                Divider().frame(maxWidth: .infinity)
                
                Label {
                    // MARK: - Password Field
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        #if os(iOS)
                        .textContentType(.newPassword)
                        #endif
                        .focused($focusedField, equals: .confirmPassword)
                        .privacySensitive(true)
                        .disabled(viewModel.loading)
                        .padding(.horizontal)
                        .onSubmit(viewModel.changePassword)
                } icon: {
                    Text("Confirm")
                        .frame(maxWidth: 80, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }.padding(.trailing, 16)
                
            }
            .padding(.leading)
            .textFieldStyle(.plain)
            Divider().frame(maxWidth: .infinity)
            Text("New password must contain at least 8 characters including uppder and lowercase letters and and at least one number")
                .font(.caption)
                .foregroundColor(Color(red: 102/255, green: 102/255, blue: 102/255))
                .multilineTextAlignment(.leading)
                .padding()
            // MARK: - Change Password button
            ZStack {
                ProgressView()
                    .opacity(viewModel.loading ? 1 : 0)
                
                Button(action: viewModel.changePassword) {
                    Text("Change Password")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .padding(.vertical)
                .opacity(viewModel.loading ? 0 : 1)
                .padding()
            }
            
            // MARK: - Response message
            
            
        }.alert("Error while trying to change password", isPresented: $viewModel.showAlert) {
            Button("Dismiss", role: .cancel) {
                viewModel.showAlert = false
            }
        } message: {
            Text(viewModel.message)
                .font(.callout)
                .tint(.red)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
        }.onChange(of: viewModel.succesfullyChangedPassword) { newValue in
            if newValue {
                self.changedPassowrd = true
                dismissAction()
            }
        }

        Spacer()
        
        
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView(changedPassowrd: .constant(false))
    }
}
