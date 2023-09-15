//
//  SymbolView.swift
//  Sibaro
//
//  Created by Armin on 9/13/23.
//

import SwiftUI

struct SymbolView: View {
    
    var icon: String
    var color: Color
    
    var backgroundColor: some ShapeStyle {
        if #available(iOS 16.0, macOS 13.0, *) {
            return color.gradient
        } else {
            return color
        }
    }
    
    var body: some View {
        Image(systemName: icon)
            .font(.largeTitle.weight(.bold))
            .background(backgroundColor)
            .background(in: Circle().inset(by: -20))
            .foregroundStyle(.white)
    }
}

struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolView(
            icon: "iphone",
            color: .blue
        )
    }
}
