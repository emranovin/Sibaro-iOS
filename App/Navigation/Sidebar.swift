//
//  Sidebar.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI

struct Sidebar: View {
    
    @State var selection: Panel? = .apps
    
    var body: some View {
        Group {
            if #available(iOS 16.0, macOS 13.0, *) {
                NavigationSplitView {
                    sidebarList
                } detail: {
                    NavigationStack {
                        selection?.view()
                            .navigationTitle(selection?.title ?? "Sibaro")
                    }
                }
            } else {
                NavigationView {
                    sidebarList
                        .listStyle(.sidebar)
                        .navigationTitle("Sibaro")
                    
                    Label("Select a tab from menu", systemImage: "sidebar.leading")
                        .foregroundStyle(.secondary)
                }
            }
            
        }
        #if os(macOS)
        .frame(minWidth: 1000)
        #endif
    }
    
    var sidebarList: some View {
        List(selection: $selection) {
            ForEach(Panel.allCases, id: \.self) { item in
                Group {
                    if #available(iOS 16.0, *) {
                        NavigationLink(value: item) {
                            Label(item.title, systemImage: item.icon)
                        }
                    } else {
                        NavigationLink(
                            tag: item,
                            selection: $selection
                        ) {
                            item.view()
                                .navigationTitle(selection?.title ?? "Sibaro")
                        } label: {
                            Label(item.title, systemImage: item.icon)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Sibaro")
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
    }
}
