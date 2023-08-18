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
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundStyle(.white, Color.accentColor.gradient)
                        .font(.largeTitle)
                    
                    Text(viewModel.userName)
                        .font(.title)
                }
                .fontWeight(.medium)
            }
            
            Section {
                
                ZStack(alignment: .leading) {
                    NavigationLink {
                        ChangePasswordView()
                    } label: {
                        EmptyView()
                    }
                    ProfileActionRow(icon: "key", color: .orange, title: "Change Password")
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
                        .presentationDetents([.fraction(0.6), .large])
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
                        color: .red,
                        title: "Logout",
                        arrow: .action
                    )
                }
            }
        }
    }
}

struct ProfileActionRow: View {
    var action: (() -> ())? = nil
    var icon: String
    var color: Color
    var title: LocalizedStringKey
    
    var body: some View {
        Button {
            action?()
        } label: {
            SettingsItemView(
                icon: icon,
                color: color,
                title: title
            )
        }
        #if os(macOS)
        .buttonStyle(.borderless)
        #endif
    }
}

struct SettingsItemView: View {
    var icon: String
    var color: Color
    var title: LocalizedStringKey
    var rotation: Double = 0
    var arrow: SettingsRowArrow? = nil
    
    enum SettingsRowArrow {
        case link
        case action
    }
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Image(systemName: icon)
                    .rotationEffect(.degrees(rotation))
                    .font(Font.system(size: 14, weight: .medium))
                    .foregroundStyle(color == .white ? .blue : .white)
                    .shadow(radius: 2)
            }
            .frame(width: 28, height: 28)
            .background(color.gradient)
            .cornerRadius(6)
            .shadow(radius: 0.5)
            
            Text(title)
                .foregroundColor(.primary)
            
            if let arrow {
                Spacer()
                Group {
                    switch arrow {
                    case .link:
                        Image(systemName: "arrow.up.forward")
                    case .action:
                        Image(systemName: "chevron.forward")
                    }
                }
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(.tertiary)
                .tint(.primary)
            }
        }
        .contentShape(Rectangle())
    }
}

struct ProfileView_Previews: PreviewProvider {
    
    static var previews: some View {
        ProfileView()
    }
}
