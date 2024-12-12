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
    
    @StateObject private var viewModel: ViewModel
    
    var logout: () -> Void
    
    init(api: SdkBringYourApi, logout: @escaping () -> Void) {
        _viewModel = StateObject.init(wrappedValue: ViewModel(
            api: api
        ))
        self.logout = logout
        
        
        // adds clear button to search providers text field
        UITextField.appearance().clearButtonMode = .whileEditing
    }
    
    var body: some View {
        
        VStack {
            Text("Connect View!!")
            
            Spacer().frame(height: 32)
            
            Button(action: logout) {
                Text("Logout")
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .bottomSheet(
            bottomSheetPosition: $viewModel.bottomSheetPosition,
            switchablePositions: viewModel.bottomSheetSwitchablePositions,
            headerContent: {
                
                VStack {
                 
                    if let selectedProvider = viewModel.selectedProvider {
                        ProviderListItemView(
                            name: selectedProvider.name,
                            providerCount: selectedProvider.providerCount,
                            color: viewModel.getProviderColor(selectedProvider),
                            isSelected: false,
                            setSelectedProvider: {}
                        )
                    } else {
                        ProviderListItemView(
                            name: "Best available provider",
                            providerCount: nil,
                            color: Color.urCoral,
                            isSelected: false,
                            setSelectedProvider: {
                                viewModel.setSelectedProvider(nil)
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
                setSelectedProvider: viewModel.setSelectedProvider,
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
        logout: {}
    )
}
