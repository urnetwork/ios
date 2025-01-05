//
//  ConnectView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import SwiftUI
import URnetworkSdk
import BottomSheet

struct ConnectView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var deviceManager: GlobalStore
    @Environment(\.requestReview) private var requestReview
    
    @StateObject private var viewModel: ViewModel
    
    var logout: () -> Void
    var api: SdkBringYourApi
    
    init(api: SdkBringYourApi, logout: @escaping () -> Void, connectViewController: SdkConnectViewController?) {
        _viewModel = StateObject.init(wrappedValue: ViewModel(
            api: api,
            connectViewController: connectViewController
        ))
        self.logout = logout
        self.api = api
        
        // adds clear button to search providers text field
        UITextField.appearance().clearButtonMode = .whileEditing
    }
    
    var body: some View {
        
        VStack {
            
            HStack {
                Spacer()
                AccountMenu(
                    isGuest: false,
                    logout: logout,
                    api: api
                )
            }
            .frame(height: 32)
            
            Spacer()
            
            ConnectButtonView(
                gridPoints:
                    viewModel.gridPoints,
                gridWidth: viewModel.gridWidth,
                connectionStatus: viewModel.connectionStatus,
                windowCurrentSize: viewModel.windowCurrentSize,
                connect: viewModel.connect,
                disconnect: viewModel.disconnect
            )
            
            Spacer()

        }
        .onAppear {
            
            /**
             * Create callback function for prompting rating
             */
            viewModel.requestReview = {
                Task {
                 
                    if deviceManager.device?.getShouldShowRatingDialog() ?? false {
                        try await Task.sleep(for: .seconds(2))
                        requestReview()
                    }
                    
                }
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .bottomSheet(
            bottomSheetPosition: $viewModel.bottomSheetPosition,
            switchablePositions: viewModel.bottomSheetSwitchablePositions,
            headerContent: {
                
                VStack {
                 
                    if let selectedProvider = viewModel.selectedProvider, selectedProvider.connectLocationId?.bestAvailable != true {
                        ProviderListItemView(
                            name: selectedProvider.name,
                            providerCount: selectedProvider.providerCount,
                            color: viewModel.getProviderColor(selectedProvider),
                            isSelected: false,
                            connect: {
                                viewModel.connect()
                            }
                        )
                    } else {
                        ProviderListItemView(
                            name: "Best available provider",
                            providerCount: nil,
                            color: Color.urCoral,
                            isSelected: false,
                            connect: {
                                viewModel.connect()
                            }
                        )
                    }
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(themeManager.currentTheme.textFaintColor)
                        TextField("", text: $viewModel.searchQuery, prompt: Text("Search")
                                  // placeholder color
                            .foregroundColor(themeManager.currentTheme.textFaintColor)
                        )
                        // color of entered text
                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 5)
                    .background(RoundedRectangle(cornerRadius: 10).fill(themeManager.currentTheme.tintedBackgroundBase))
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 16)
                    
                }
                
            }
        ) {
            
            ProviderListSheetView(
                selectedProvider: viewModel.selectedProvider,
                connect: viewModel.connect,
                // setSelectedProvider: viewModel.setSelectedProvider,
                providerCountries: viewModel.providerCountries,
                providerPromoted: viewModel.providerPromoted,
                providerDevices: viewModel.providerDevices,
                providerRegions: viewModel.providerRegions,
                providerCities: viewModel.providerCities,
                providerBestSearchMatches: viewModel.providerBestSearchMatches
            )
            
        }
        .dragIndicatorColor(themeManager.currentTheme.textFaintColor)
        .customBackground(
            themeManager.currentTheme.backgroundColor
                .cornerRadius(12)
                .shadow(color: themeManager.currentTheme.borderBaseColor, radius: 1, x: 0, y: 0)
        )
        .enableAppleScrollBehavior()
    }
}

#Preview {
    ConnectView(
        api: SdkBringYourApi(),
        logout: {},
        connectViewController: nil
    )
}
