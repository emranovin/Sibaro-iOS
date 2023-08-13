//
//  EmptyStateView.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI

struct EmptyStateView: View {
    
    var icon: String? = nil
    var isLoading: Bool = false
    var showAlt: Bool = false
    var title: String
    var actionTitle: String?
    var action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 32) {
            if isLoading {
                ProgressView()
                    .controlSize(.large)
                    .tint(Color.accentColor)
            } else if let icon {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .dynamicTypeSize(.accessibility5)
                    .foregroundStyle(.indigo)
                    .symbolRenderingMode(.hierarchical)
            }
            
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            if let action, let actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
