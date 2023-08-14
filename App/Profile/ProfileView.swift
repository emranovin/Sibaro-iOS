//
//  ProfileView.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var account: Account
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundStyle(Color.accentColor.gradient)
                            .font(.largeTitle)
                        
                        Text(account.storageUsername)
                            .font(.title)
                    }
                    .fontWeight(.bold)
                }
                
                Section {
                    NavigationLink {
                        DesiredAppView()
                    } label: {
                        SettingsItemView(
                            icon: "list.bullet.clipboard.fill",
                            color: .blue,
                            title: "Request New App"
                        )
                    }
                    
                    Button(action: logout) {
                        SettingsItemView(
                            icon: "rectangle.portrait.and.arrow.forward",
                            color: .red,
                            title: "Logout"
                        )
                    }
                    
                    #if os(macOS)
                    .buttonStyle(.borderless)
                    #endif
                }
            }
        }
    }

    func logout() {
        Task {
            try await account.logout()
        }
    }
}

struct SettingsItemView: View {
    var icon: String
    var color: Color
    var title: LocalizedStringKey
    var rotation: Double = 0
    var showAsLink: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Image(systemName: icon)
                    .rotationEffect(.degrees(rotation))
                    .font(Font.system(size: 14, weight: .medium))
                    .foregroundColor(color == .white ? .blue : .white)
                    .shadow(radius: 2)
            }
            .frame(width: 28, height: 28)
            .background(color.gradient)
            .cornerRadius(6)
            .shadow(radius: 0.5)
            
            Text(title)
                .foregroundColor(.primary)
            
            if showAsLink {
                Spacer()
                Image(systemName: "arrow.up.forward")
                    .font(Font.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .opacity(0.55)
            }
        }
        .contentShape(Rectangle())
    }
}

struct ProfileView_Previews: PreviewProvider {
    @StateObject static var account = Account()
    
    static var previews: some View {
        ProfileView()
            .environmentObject(account)
    }
}
