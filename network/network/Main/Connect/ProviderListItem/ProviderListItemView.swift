//
//  ProviderListItem.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/11.
//

import SwiftUI
import URnetworkSdk

struct ProviderListItemView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var name: String
    var providerCount: Int32?
    var color: Color
    var isSelected: Bool
    var connect: () -> Void
    
    var body: some View {
        HStack {
            
            Circle()
                .frame(width: 40, height: 40)
                .foregroundColor(color)
            
            Spacer().frame(width: 16)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(themeManager.currentTheme.bodyFont)
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                if let providerCount = providerCount, providerCount > 0 {
                    Text("\(providerCount) providers")
                        .font(themeManager.currentTheme.secondaryBodyFont)
                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
            }
            
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            connect()
        }
    }
}

#Preview {
    
    let themeManager = ThemeManager.shared
    
    VStack {
        ProviderListItemView(
            name: "Tokyo",
            providerCount: 1000,
            color: Color (hex: "CC3363"),
            isSelected: true,
            connect: {}
        )
    }
    .environmentObject(themeManager)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(themeManager.currentTheme.backgroundColor)
}
