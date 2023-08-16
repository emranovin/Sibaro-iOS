//
//  Sidebar.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI

struct Sidebar: View {
    
    @State var selection: Panel? = .apps
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(Panel.allCases, id: \.self) { item in
                    NavigationLink(value: item) {
                        Label(item.title, systemImage: item.icon)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Sibaro")
        } detail: {
            NavigationStack(path: $path) {
                selection?.view()
            }
        }
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
    }
}
