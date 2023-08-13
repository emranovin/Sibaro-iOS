//
//  LoginView.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI

struct LoginView: View {
    
    /// Status
    @State var loading: Bool = false
    @State var message: String = ""
    
    /// Fields
    @State var username: String = ""
    @State var password: String = ""
    @FocusState private var focusedField: LoginField?
    
    /// Account management
    @EnvironmentObject var account: Account
    
    private enum LoginField: Hashable {
        case username, password
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                content
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
            }
            .clipped()
        }
        
        #if os(macOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            VisualEffectBlur(state: .active)
                .edgesIgnoringSafeArea(.all)
        }
        #endif
    }
    
    var content: some View {
        VStack {
            Spacer()
            
            // MARK: - App name
            Text("Sibaro")
                .font(.largeTitle)
                .dynamicTypeSize(.accessibility1)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.blue.gradient)
                .shadow(color: .indigo.opacity(0.5), radius: 1)
                
            
            // MARK: - Fields
            VStack(alignment: .leading) {
                Label {
                    // MARK: - Username Field
                    TextField("Username", text: $username)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .username)
                        .disabled(loading)
                        .frame(maxWidth: 300)
                        .padding()
                        .onSubmit {
                            focusedField = .password
                        }
                } icon: {
                    Image(systemName: "at")
                }
                
                HStack {
                    Label {
                        // MARK: - Password Field
                        SecureField("Password", text: $password)
                            .focused($focusedField, equals: .password)
                            .privacySensitive(true)
                            .submitLabel(.done)
                            .disabled(loading)
                            .frame(maxWidth: 300)
                            .padding()
                            .onSubmit(login)
                    } icon: {
                        Image(systemName: "lock")
                    }
                }
            }
            .textFieldStyle(.plain)
            .padding()
            .background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: 16)
            )
            
            // MARK: - Login button
            ZStack {
                ProgressView()
                    .opacity(loading ? 1 : 0)
                
                Button(action: login) {
                    Text("Login")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(maxWidth: 150)
                }
                .controlSize(.large)
                #if os(iOS)
                .buttonBorderShape(.capsule)
                #endif
                .buttonStyle(.borderedProminent)
                .padding()
                .opacity(loading ? 0 : 1)
            }
            
            // MARK: - Response message
            Text(message)
                .font(.callout)
                .foregroundColor(.red)
            
            Spacer()
        }
        .padding()
    }
}

extension LoginView {
    func login() {
        Task {
            withAnimation {
                focusedField = nil
                self.loading = true
                self.message = ""
            }
            do {
                try await account.login(
                    username: username,
                    password: password
                )
            } catch {
                print(error)
                if let error = error as? RequestError {
                    switch error {
                    case .unauthorized(let data):
                        let decodedResponse = try JSONDecoder().decode(LoginMessage.self, from: data)
                        message = decodedResponse.detail
                    default:
                        message = error.description
                    }
                }
            }
            withAnimation {
                self.loading = false
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
