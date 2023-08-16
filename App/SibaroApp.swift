//
//  SibaroApp.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI

@main
struct SibaroApp: App {
    @StateObject var i18n: I18nService = I18nService()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(i18n)
        }
    }
}
