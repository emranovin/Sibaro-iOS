//
//  SettingsSymbolView.swift
//  Sibaro
//
//  Created by Armin on 9/14/23.
//

import SwiftUI

struct SettingsSymbolView: View {
    
    var icon: String
    var altIcon: String? = nil
    var color: Color
    
    var iconPreview: String {
        if #available(iOS 16.0, macOS 13.0, *) {
            return icon
        } else {
            return altIcon ?? icon
        }
    }
    
    var body: some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            content
                .background(color.gradient)
                .cornerRadius(6)
                .shadow(radius: 0.5)
        } else {
            content
                .background(color)
                .cornerRadius(6)
                .shadow(radius: 0.5)
        }
    }
    
    var content: some View {
        ZStack {
            Image(systemName: iconPreview)
                .font(Font.system(size: 14, weight: .medium))
                .foregroundStyle(color == .white ? .blue : .white)
                .shadow(radius: 2)
        }
        .frame(width: 28, height: 28)
    }
}

struct SettingsSymbolView_Previews: PreviewProvider {
    
    static var previews: some View {
        SettingsSymbolView(
            icon: "rectangle.portrait.and.arrow.forward",
            altIcon: "rectangle.portrait.and.arrow.right",
            color: .red
        )
    }
}
