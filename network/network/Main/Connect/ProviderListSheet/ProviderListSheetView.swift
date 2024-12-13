//
//  ProviderListSheetView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import SwiftUI
import URnetworkSdk

struct ProviderListSheetView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var selectedProvider: SdkConnectLocation?
    var setSelectedProvider: (SdkConnectLocation?) -> Void
    
    /**
     * Provider lists
     */
    var providerCountries: [SdkConnectLocation]
    var providerPromoted: [SdkConnectLocation]
    var providerDevices: [SdkConnectLocation]
    var providerRegions: [SdkConnectLocation]
    var providerCities: [SdkConnectLocation]
    var providerBestSearchMatches: [SdkConnectLocation]
    
    
    var body: some View {
        // using a VStack instead of list due to https://github.com/lucaszischka/BottomSheet/issues/169#issuecomment-2526693338
        VStack {
            
            ProviderListGroup(
                groupName: "Best Search Matches",
                providers: providerBestSearchMatches,
                selectedProvider: selectedProvider,
                setSelectedProvider: setSelectedProvider
            )
            ProviderListGroup(
                groupName: "Promoted Locations",
                providers: providerPromoted,
                selectedProvider: selectedProvider,
                setSelectedProvider: setSelectedProvider
            )
            ProviderListGroup(
                groupName: "Countries",
                providers: providerCountries,
                selectedProvider: selectedProvider,
                setSelectedProvider: setSelectedProvider
            )
            ProviderListGroup(
                groupName: "Regions",
                providers: providerRegions,
                selectedProvider: selectedProvider,
                setSelectedProvider: setSelectedProvider
            )
            ProviderListGroup(
                groupName: "Cities",
                providers: providerCities,
                selectedProvider: selectedProvider,
                setSelectedProvider: setSelectedProvider
            )
            ProviderListGroup(
                groupName: "Devices",
                providers: providerDevices,
                selectedProvider: selectedProvider,
                setSelectedProvider: setSelectedProvider
            )
        }
    }
}

private struct ProviderListGroup: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var groupName: String
    var providers: [SdkConnectLocation]
    var selectedProvider: SdkConnectLocation?
    var setSelectedProvider: (SdkConnectLocation) -> Void
    
    var body: some View {
        if !providers.isEmpty {
            Section(
                header: HStack {
                    Text(groupName)
                        .font(themeManager.currentTheme.bodyFont)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    Spacer()
                }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            ) {
                ForEach(providers, id: \.connectLocationId) { provider in
                    ProviderListItemView(
                        name: provider.name,
                        providerCount: provider.providerCount,
                        color: getProviderColor(provider),
                        isSelected: selectedProvider != nil && selectedProvider?.connectLocationId?.cmp(provider.connectLocationId) == 0,
                        setSelectedProvider: {
                            setSelectedProvider(provider)
                        }
                    )
                }
            }
            
        }
    }
    
}

#Preview {
    
    let themeManager = ThemeManager.shared
    
    var providerCountries: [SdkConnectLocation] = [
        {
            let p = SdkConnectLocation()
            p.name = "United States"
            p.providerCount = 73
            p.countryCode = "US"
            p.locationType = SdkLocationTypeCountry
            p.connectLocationId = SdkConnectLocationId()
            return p
        }(),
        {
            let p = SdkConnectLocation()
            p.name = "Mexico"
            p.providerCount = 45
            p.countryCode = "MX"
            p.locationType = SdkLocationTypeCountry
            p.connectLocationId = SdkConnectLocationId()
            return p
        }(),
        {
            let p = SdkConnectLocation()
            p.name = "Canada"
            p.providerCount = 23
            p.countryCode = "CA"
            p.locationType = SdkLocationTypeCountry
            p.connectLocationId = SdkConnectLocationId()
            return p
        }()
    ]
    
    var providerCities: [SdkConnectLocation] = [
        {
            let p = SdkConnectLocation()
            p.name = "New York City"
            p.providerCount = 25
            p.countryCode = "US"
            p.connectLocationId = SdkConnectLocationId()
            return p
        }(),
        {
            let p = SdkConnectLocation()
            p.name = "San Francisco"
            p.providerCount = 76
            p.countryCode = "US"
            p.connectLocationId = SdkConnectLocationId()
            return p
        }(),
        {
            let p = SdkConnectLocation()
            p.name = "Chicago"
            p.providerCount = 12
            p.countryCode = "US"
            p.connectLocationId = SdkConnectLocationId()
            return p
        }()
    ]
    
    return VStack {
        ProviderListSheetView(
            selectedProvider: nil,
            setSelectedProvider: {_ in },
            providerCountries: providerCountries,
            providerPromoted: [],
            providerDevices: [],
            providerRegions: [],
            providerCities: providerCities,
            providerBestSearchMatches: []
        )
    }
    .environmentObject(themeManager)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(themeManager.currentTheme.backgroundColor)
    
}
