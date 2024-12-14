//
//  AccountView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import SwiftUI
import URnetworkSdk

struct AccountNavStackView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel: ViewModel = ViewModel()
    
    @StateObject var accountPreferencesViewModel: AccountPreferencesViewModel
    
    var api: SdkBringYourApi
    var device: SdkBringYourDevice
    @Binding var provideWhileDisconnected: Bool
    
    init(
        api: SdkBringYourApi,
        device: SdkBringYourDevice,
        provideWhileDisconnected: Binding<Bool>
    ) {
        self.api = api
        _accountPreferencesViewModel = StateObject.init(wrappedValue: AccountPreferencesViewModel(
                api: api
            )
        )
        self.device = device
        self._provideWhileDisconnected = provideWhileDisconnected
    }
    
    var body: some View {
        NavigationStack(
            path: $viewModel.navigationPath
        ) {
            AccountRootView(
                navigate: viewModel.navigate
            )
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationDestination(for: AccountNavigationPath.self) { path in
                switch path {
                    
                case .profile:
                    ProfileView(
                        api: api,
                        back: viewModel.back
                    )
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Profile")
                                .font(themeManager.currentTheme.toolbarTitleFont).fontWeight(.bold)
                        }
                    }
                    
                case .settings:
                    SettingsView(
                        clientId: device.clientId(),
                        provideWhileDisconnected: $provideWhileDisconnected,
                        accountPreferencesViewModel: accountPreferencesViewModel
                    )
                    .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
                    .toolbar {
                         ToolbarItem(placement: .principal) {
                             Text("Settings")
                                 .font(themeManager.currentTheme.toolbarTitleFont).fontWeight(.bold)
                         }
                    }
                    
                case .wallet:
                    WalletView(
                        api: api,
                        back: viewModel.back
                    )
                    .toolbar {
                         ToolbarItem(placement: .principal) {
                             Text("Wallet")
                                 .font(themeManager.currentTheme.toolbarTitleFont).fontWeight(.bold)
                         }
                    }
                }
            }
        }
    }
}

#Preview {
    AccountNavStackView(
        api: SdkBringYourApi(),
        device: SdkBringYourDevice(),
        provideWhileDisconnected: .constant(true)
    )
    .environmentObject(ThemeManager.shared)
}
