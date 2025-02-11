//
//  ConnectView-macOS.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/02/11.
//

import SwiftUI
import URnetworkSdk

#if os(macOS)
struct ConnectView_macOS: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var snackbarManager: UrSnackbarManager
    @Environment(\.requestReview) private var requestReview
    
    @StateObject private var connectViewModel: ConnectViewModel
    
    @State var isRefreshing: Bool = false
    
    var logout: () -> Void
    var api: SdkApi
    
    init(
        api: SdkApi,
        logout: @escaping () -> Void,
        device: SdkDeviceRemote?,
        connectViewController: SdkConnectViewController?
    ) {
        _connectViewModel = StateObject.init(wrappedValue: ConnectViewModel(
            api: api,
            device: device,
            connectViewController: connectViewController
        ))
        self.logout = logout
        self.api = api
        
    }
    
    var body: some View {
            
        ScrollView {
         
            VStack {
                ConnectButtonView(
                    gridPoints:
                        connectViewModel.gridPoints,
                    gridWidth: connectViewModel.gridWidth,
                    connectionStatus: connectViewModel.connectionStatus,
                    windowCurrentSize: connectViewModel.windowCurrentSize,
                    connect: connectViewModel.connect,
                    disconnect: connectViewModel.disconnect
                )
                
                ProviderTable(
                    selectedProvider: connectViewModel.selectedProvider,
                    connect: { provider in
                        connectViewModel.connect(provider)
                        // providerListSheetViewModel.isPresented = false
                    },
                    connectBestAvailable: {
                        connectViewModel.connectBestAvailable()
                        // providerListSheetViewModel.isPresented = false
                    },
                    providerCountries: connectViewModel.providerCountries,
                    providerPromoted: connectViewModel.providerPromoted,
                    providerDevices: connectViewModel.providerDevices,
                    providerRegions: connectViewModel.providerRegions,
                    providerCities: connectViewModel.providerCities,
                    providerBestSearchMatches: connectViewModel.providerBestSearchMatches,
                    searchQuery: $connectViewModel.searchQuery,
                    refresh: {
                        Task {
                            isRefreshing = true
                            let _ = await connectViewModel.filterLocations(connectViewModel.searchQuery)
                            isRefreshing = false
                        }
                    },
                    isRefreshing: isRefreshing
                )
//                    .searchable(
//                        text: $connectViewModel.searchQuery,
//                        // placement: .navigationBarDrawer(displayMode: .always),
//                        prompt: "Search providers"
//                    )
            }
            
        }
        
    }
}

struct ProviderTable: View {
    
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
    
    @Binding var searchQuery: String
    
    var refresh: () -> Void
    var isRefreshing: Bool
    
    var body: some View {
        
        VStack {
            

//            .padding(.horizontal, 16)
//            .background(themeManager.currentTheme.tintedBackgroundBase)
         
            HStack {
                Text("Available providers")
                    .font(themeManager.currentTheme.toolbarTitleFont)
                Spacer()
                
                Button(action: refresh) {
                    // Text("refresh")
                    
                    Image(nsImage: NSImage(named: NSImage.refreshTemplateName)!)
                    
                }
                .buttonStyle(.plain)
                .disabled(isRefreshing)
                // .background(Color.clear)
            }
            
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
            // .listStyle(.plain)
    //                .searchable(
    //                    text: $searchText,
    //                    prompt: "Search providers"
    //                )
            .frame(height: 300)
            .cornerRadius(8)
            .searchable(
                text: $searchQuery,
                // placement: .toolbar,
                prompt: "Search providers"
            )
            
        }
//        .searchable(
//            text: $searchQuery,
//            // placement: .navigationBarDrawer(displayMode: .always),
//            prompt: "Search providers"
//        )
        .padding(32)
        
    }
}

//#Preview {
//    ConnectView_macOS()
//}
#endif
