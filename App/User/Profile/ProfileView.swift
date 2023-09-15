//
//  ProfileView.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        List {
            Section {
                HStack {
                    if #available(iOS 16.0, macOS 13.0, *) {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundStyle(.white, Color.accentColor.gradient)
                            .font(.largeTitle)
                            .fontWeight(.medium)
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundStyle(.white, Color.accentColor)
                            .font(.largeTitle.weight(.medium))
                    }
                    
                    Text(viewModel.userName)
                        .font(.title.weight(.medium))
                }
            }
            
            Section {
                /// Reset password
                Button {
                    viewModel.showChangePass.toggle()
                } label: {
                    SettingsItemView(
                        icon: "key.fill",
                        color: .orange,
                        title: "Change Password",
                        arrow: .action
                    )
                }
                #if os(macOS)
                .buttonStyle(.borderless)
                #endif
                .sheet(isPresented: $viewModel.showChangePass) {
                    ChangePasswordView()
                        #if os(macOS)
                        .frame(
                            minWidth: 450,
                            idealWidth: 450,
                            minHeight: 450,
                            idealHeight: 450
                        )
                        #endif
                }
                
                /// App request
                Button {
                    viewModel.showAppSuggestion.toggle()
                } label: {
                    SettingsItemView(
                        icon: "app.badge.checkmark.fill",
                        color: .blue,
                        title: "Request New App",
                        arrow: .action
                    )
                }
                #if os(macOS)
                .buttonStyle(.borderless)
                #endif
                .sheet(isPresented: $viewModel.showAppSuggestion) {
                    SubmitAppView()
                        #if os(macOS)
                        .frame(minWidth: 400, minHeight: 350)
                        #endif
                }
                
                /// Feedback
                Link(destination: URL(string: "https://github.com/emranovin/Sibaro-iOS/issues")!) {
                    SettingsItemView(
                        icon: "exclamationmark.bubble.fill",
                        color: .purple,
                        title: "Feedback",
                        arrow: .link
                    )
                }
                
                /// SourceCode
                Link(destination: URL(string: "https://github.com/emranovin/Sibaro-iOS/")!) {
                    SettingsItemView(
                        icon: "curlybraces",
                        color: .white,
                        title: "Source code",
                        arrow: .link
                    )
                }
            }
            
            Section {
                /// Logout
                Button {
                    viewModel.showLogoutDialog.toggle()
                } label: {
                    SettingsItemView(
                        icon: "rectangle.portrait.and.arrow.forward",
                        altIcon: "rectangle.portrait.and.arrow.right",
                        color: .red,
                        title: "Logout",
                        arrow: .action
                    )
                }
                #if os(macOS)
                .buttonStyle(.borderless)
                #endif
                .alert(
                    "Are you sure you want to logout?",
                    isPresented: $viewModel.showLogoutDialog
                ) {
                    Button("Logout", role: .destructive) {
                        viewModel.logout()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
