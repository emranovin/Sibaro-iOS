//
//  MainView.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI

struct MainView: View {
    
    @StateObject var viewModel = ViewModel()
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    var body: some View {
        ZStack {
            if viewModel.isAuthenticated {
                #if os(iOS)
                if horizontalSizeClass == .compact {
                    TabNavigation()
                } else {
                    Sidebar()
                }
                #else
                Sidebar()
                #endif
            } else {
                LoginView()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    @ObservedObject static var i18n = I18nService()
    
    static var previews: some View {
        MainView()
            .environmentObject(i18n)
    }
}
