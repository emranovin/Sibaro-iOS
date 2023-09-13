//
//  SettingsItemView.swift
//  Sibaro
//
//  Created by Armin on 9/14/23.
//

import SwiftUI

struct SettingsItemView: View {
    var icon: String
    var altIcon: String? = nil
    var color: Color
    var title: LocalizedStringKey
    var rotation: Double = 0
    
    #if os(iOS)
    var arrow: SettingsRowArrow? = nil
    #else
    var arrow: SettingsRowArrow? = .action
    #endif
    
    enum SettingsRowArrow {
        case link
        case action
    }
    
    var body: some View {
        HStack(spacing: 15) {
            SettingsSymbolView(
                icon: icon,
                altIcon: altIcon,
                color: color
            )
            
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
                .font(.footnote.weight(.bold))
                .foregroundStyle(.tertiary)
                .tint(.primary)
            }
        }
        .contentShape(Rectangle())
    }
}

struct SettingsItemView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsItemView(
            icon: "lock",
            color: .orange,
            title: "Passwords"
        )
    }
}
