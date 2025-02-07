//
//  ProviderListSheetView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import SwiftUI
import URnetworkSdk

//struct ProviderListSheetView: View {
//    
//    @EnvironmentObject var themeManager: ThemeManager
//    
//    var selectedProvider: SdkConnectLocation?
//    var connect: (SdkConnectLocation) -> Void
//    var connectBestAvailable: () -> Void
//    
//    /**
//     * Provider lists
//     */
//    var providerCountries: [SdkConnectLocation]
//    var providerPromoted: [SdkConnectLocation]
//    var providerDevices: [SdkConnectLocation]
//    var providerRegions: [SdkConnectLocation]
//    var providerCities: [SdkConnectLocation]
//    var providerBestSearchMatches: [SdkConnectLocation]
//    
//    /**
//     * Close sheet
//     */
//    var setIsPresented: (Bool) -> Void
//    
//    
//    var body: some View {
//        List {
//            
//            ProviderListGroup(
//                groupName: "Best Search Matches",
//                providers: providerBestSearchMatches,
//                selectedProvider: selectedProvider,
//                connect: connect
//            )
//            ProviderListGroup(
//                groupName: "Promoted Locations",
//                providers: providerPromoted,
//                selectedProvider: selectedProvider,
//                connect: connect,
//                connectBestAvailable: connectBestAvailable,
//                isPromotedLocations: true
//            )
//            ProviderListGroup(
//                groupName: "Countries",
//                providers: providerCountries,
//                selectedProvider: selectedProvider,
//                connect: connect
//            )
//            ProviderListGroup(
//                groupName: "Regions",
//                providers: providerRegions,
//                selectedProvider: selectedProvider,
//                connect: connect
//            )
//            ProviderListGroup(
//                groupName: "Cities",
//                providers: providerCities,
//                selectedProvider: selectedProvider,
//                connect: connect
//            )
//            ProviderListGroup(
//                groupName: "Devices",
//                providers: providerDevices,
//                selectedProvider: selectedProvider,
//                connect: connect
//            )
//        }
//        .frame(minHeight: 400)
//        .listStyle(.plain)
//        .background(themeManager.currentTheme.backgroundColor)
//    }
//}

#if os(iOS)
struct ProviderListSheetView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var selectedProvider: SdkConnectLocation?
    var connect: (SdkConnectLocation) -> Void
    var connectBestAvailable: () -> Void
    
    /**
     * Provider lists
     */
    var providerCountries: [SdkConnectLocation]
    var providerPromoted: [SdkConnectLocation]
    var providerDevices: [SdkConnectLocation]
    var providerRegions: [SdkConnectLocation]
    var providerCities: [SdkConnectLocation]
    var providerBestSearchMatches: [SdkConnectLocation]
    
    /**
     * Close sheet
     */
    var setIsPresented: (Bool) -> Void
    
    @Binding var searchText: String
    
    var body: some View {
        List {
            
            ProviderListGroup(
                groupName: "Best Search Matches",
                providers: providerBestSearchMatches,
                selectedProvider: selectedProvider,
                connect: connect
            )
            ProviderListGroup(
                groupName: "Promoted Locations",
                providers: providerPromoted,
                selectedProvider: selectedProvider,
                connect: connect,
                connectBestAvailable: connectBestAvailable,
                isPromotedLocations: true
            )
            ProviderListGroup(
                groupName: "Countries",
                providers: providerCountries,
                selectedProvider: selectedProvider,
                connect: connect
            )
            ProviderListGroup(
                groupName: "Regions",
                providers: providerRegions,
                selectedProvider: selectedProvider,
                connect: connect
            )
            ProviderListGroup(
                groupName: "Cities",
                providers: providerCities,
                selectedProvider: selectedProvider,
                connect: connect
            )
            ProviderListGroup(
                groupName: "Devices",
                providers: providerDevices,
                selectedProvider: selectedProvider,
                connect: connect
            )
        }
        // .frame(minHeight: 400)
        .listStyle(.plain)
        .background(themeManager.currentTheme.backgroundColor)
    }
    
}
#elseif os(macOS)
struct ProviderListSheetView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var selectedProvider: SdkConnectLocation?
    var connect: (SdkConnectLocation) -> Void
    var connectBestAvailable: () -> Void
    
    /**
     * Provider lists
     */
    var providerCountries: [SdkConnectLocation]
    var providerPromoted: [SdkConnectLocation]
    var providerDevices: [SdkConnectLocation]
    var providerRegions: [SdkConnectLocation]
    var providerCities: [SdkConnectLocation]
    var providerBestSearchMatches: [SdkConnectLocation]
    
    /**
     * Close sheet
     */
    var setIsPresented: (Bool) -> Void
    
    @Binding var searchText: String
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
             
                
                List {
                    
                    ProviderListGroup(
                        groupName: "Best Search Matches",
                        providers: providerBestSearchMatches,
                        selectedProvider: selectedProvider,
                        connect: connect
                    )
                    ProviderListGroup(
                        groupName: "Promoted Locations",
                        providers: providerPromoted,
                        selectedProvider: selectedProvider,
                        connect: connect,
                        connectBestAvailable: connectBestAvailable,
                        isPromotedLocations: true
                    )
                    ProviderListGroup(
                        groupName: "Countries",
                        providers: providerCountries,
                        selectedProvider: selectedProvider,
                        connect: connect
                    )
                    ProviderListGroup(
                        groupName: "Regions",
                        providers: providerRegions,
                        selectedProvider: selectedProvider,
                        connect: connect
                    )
                    ProviderListGroup(
                        groupName: "Cities",
                        providers: providerCities,
                        selectedProvider: selectedProvider,
                        connect: connect
                    )
                    ProviderListGroup(
                        groupName: "Devices",
                        providers: providerDevices,
                        selectedProvider: selectedProvider,
                        connect: connect
                    )
                }
                
                .listStyle(.plain)
//                .searchable(
//                    text: $searchText,
//                    prompt: "Search providers"
//                )
                .frame(height: 300)
                
            }
            
            .searchable(
                text: $searchText,
                prompt: "Search providers"
            )
            
            .navigationTitle("Available providers")
            // .toolbarTitleDisplayMode(.inline)
            
            
//            .toolbar {
//                
//                ToolbarItemGroup(placement: .automatic) {
//                    HStack {
//                        Text("Available providers")
//                    }
//                }
//
////                ToolbarItem(placement: .automatic) {
////                    Text("Available providers")
////                        .font(themeManager.currentTheme.toolbarTitleFont).fontWeight(.bold)
////                }
//
////                ToolbarItem(placement: .cancellationAction) {
////                    Button(action: {
////                        setIsPresented(false)
////                        // providerListSheetViewModel.isPresented = false
////                    }) {
////                        Image(systemName: "xmark")
////                    }
////                }
//
//            }
            
            
//            .searchable(
//                text: $searchText,
//                prompt: "Search providers"
//            )
            
            
            // .navigationTitle("Available providers")
            
            // .navigationBarTitleDisplayMode(.inline)
            

            
//            .refreshable {
//                let _ = await viewModel.filterLocations(viewModel.searchQuery)
//            }
//            .onAppear {
//                Task {
//                    let _ = await viewModel.filterLocations(viewModel.searchQuery)
//                }
//            }
            // .background(themeManager.currentTheme.backgroundColor)
        }
    }
    
}
#endif

private struct ProviderListGroup: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var groupName: String
    var providers: [SdkConnectLocation]
    var selectedProvider: SdkConnectLocation?
    var connect: (SdkConnectLocation) -> Void
    var connectBestAvailable: () -> Void = {}
    var isPromotedLocations: Bool = false
    
    var body: some View {
        if !providers.isEmpty {
            Section(
                header: HStack {
                    Text(groupName)
                        .textCase(nil) // for some reason, header text is all caps by default in swiftui
                        .font(themeManager.currentTheme.bodyFont)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    Spacer()
                }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            ) {
                
                if isPromotedLocations {
                    ProviderListItemView(
                        name: "Best available provider",
                        providerCount: nil,
                        color: Color.urCoral,
                        isSelected: false,
                        connect: {
                            connectBestAvailable()
                        }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
                
                ForEach(providers, id: \.connectLocationId) { provider in
                    ProviderListItemView(
                        name: provider.name,
                        providerCount: provider.providerCount,
                        color: getProviderColor(provider),
                        isSelected: selectedProvider != nil && selectedProvider?.connectLocationId?.cmp(provider.connectLocationId) == 0,
                        connect: {
                            connect(provider)
                        }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
            }
            .listRowBackground(Color.clear)
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
    
    VStack {
        ProviderListSheetView(
            selectedProvider: nil,
            connect: {_ in },
            connectBestAvailable: {},
            providerCountries: providerCountries,
            providerPromoted: [],
            providerDevices: [],
            providerRegions: [],
            providerCities: providerCities,
            providerBestSearchMatches: [],
            setIsPresented: {_ in },
            searchText: .constant("")
        )
    }
    .environmentObject(themeManager)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(themeManager.currentTheme.backgroundColor)
    
}
