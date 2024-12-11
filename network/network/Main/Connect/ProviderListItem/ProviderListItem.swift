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
                .foregroundColor(color) // or any color you want
            
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
            
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
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
            provider: provider
        )
    }
    .environmentObject(themeManager)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(themeManager.currentTheme.backgroundColor)
}
