//
//  TabNavigation.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

#if os(iOS)
import SwiftUI

struct TabNavigation: View {
    
    @State private var path = NavigationPath()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        TabView {
            ForEach(Panel.allCases, id: \.self) { item in
                let menuText = Text(item.title)
                NavigationStack(path: $path) {
                    item.view()
                        .navigationTitle(item.title)
                }
                .tabItem {
                    Label(item.title, systemImage: item.icon)
                        .accessibility(label: menuText)
                }
                .tag(item.hashValue)
            }
        }
    }
}

struct TabNavigation_Previews: PreviewProvider {
    
    @ObservedObject static var i18n = I18nService()
    
    static var previews: some View {
        TabNavigation()
            .environmentObject(i18n)
    }
}
#endif
