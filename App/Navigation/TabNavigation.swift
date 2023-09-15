//
//  TabNavigation.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

#if os(iOS)
import SwiftUI

struct TabNavigation: View {
    
    var body: some View {
        TabView {
            ForEach(Panel.allCases, id: \.self) { item in
                let menuText = Text(item.title)
                Group {
                    if #available(iOS 16.0, *) {
                        NavigationStack {
                            item.view()
                                .navigationTitle(item.title)
                        }
                    } else {
                        NavigationView {
                            item.view()
                                .navigationTitle(item.title)
                        }
                    }
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
