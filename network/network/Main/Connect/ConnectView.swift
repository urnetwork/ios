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
    
    // @State var bottomSheetPosition: BottomSheetPosition = .relativeBottom(0.2)
    
    init(api: SdkBringYourApi, logout: @escaping () -> Void) {
        _viewModel = StateObject.init(wrappedValue: ViewModel(
            api: api
        ))
        self.logout = logout
    }
    
    var body: some View {
        
        // ZStack {
            
            VStack {
                Text("Connect View!!")
                
                Spacer().frame(height: 32)
                
                Button(action: logout) {
                    Text("Logout")
                }
                
                Spacer().frame(height: 32)
                
//                Button(action: {
//                    viewModel.isPresentingProvidersList = true
//                }) {
//                    Text("Testing")
//                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .bottomSheet(
                bottomSheetPosition: $viewModel.bottomSheetPosition,
                switchablePositions: [.relativeBottom(0.2), .relativeTop(0.95)],
                headerContent: {
                    HStack {
                        Text("hello world")
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
