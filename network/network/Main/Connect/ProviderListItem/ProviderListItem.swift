//
//  ProviderListItem.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/11.
//

import SwiftUI
import URnetworkSdk

struct ProviderListItem: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var provider: SdkConnectLocation
    var isSelected: Bool
    var setSelectedProvider: (SdkConnectLocation) -> Void
    
    var color: Color {
        if provider.locationType == SdkLocationTypeCountry {
            return Color(hex: SdkGetColorHex(provider.countryCode))
        } else {
            return Color(hex: SdkGetColorHex(provider.connectLocationId?.string()))
        }
    }
    
    var body: some View {
        HStack {
            
            Circle()
                .frame(width: 40, height: 40)
                .foregroundColor(color)
            
            Spacer().frame(width: 16)
            
            VStack(alignment: .leading) {
                Text(provider.name)
                    .font(themeManager.currentTheme.bodyFont)
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                Text("\(provider.providerCount) providers")
                    .font(themeManager.currentTheme.secondaryBodyFont)
                    .foregroundColor(themeManager.currentTheme.textMutedColor)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
            }
            
        }
//        .onTapGesture {
//            setSelectedProvider(provider)
//        }
        // .background(Color.clear)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            setSelectedProvider(provider)
        }
    }
}

#Preview {
    
    let provider: SdkConnectLocation = {
        let p = SdkConnectLocation()
        p.name = "Tokyo"
        p.providerCount = 1000
        p.countryCode = "JP"
        return p
    }()
    
    let themeManager = ThemeManager.shared
    
    return VStack {
        ProviderListItem(
            provider: provider,
            isSelected: true,
            setSelectedProvider: {_ in }
        )
    }
    .environmentObject(themeManager)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(themeManager.currentTheme.backgroundColor)
}
