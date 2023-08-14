//
//  SibaroApp.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI

@main
struct SibaroApp: App {
    @ObservedObject var language = LanguageService()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(language)
        }
    }
}
