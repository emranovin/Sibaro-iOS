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
        switch viewModel.state {
        case .loading:
            loading
        case .main:
            main
        case .login:
            LoginView()
        case .error(let error):
            self.error(error)
        }
    }
    
    @ViewBuilder var main: some View {
        #if os(iOS)
        if horizontalSizeClass == .compact {
            TabNavigation()
        } else {
            Sidebar()
        }
        #else
        Sidebar()
        #endif
    }
    
    var loading: some View {
        Text("Loading")
    }
    
    func error(_ error: Error) -> some View {
        Text("Error")
    }
}


struct MainView_Previews: PreviewProvider {
    @ObservedObject static var i18n = I18nService()
    
    static var previews: some View {
        MainView()
            .environmentObject(i18n)
    }
}
