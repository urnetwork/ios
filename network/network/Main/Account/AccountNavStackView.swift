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
    @StateObject var accountWalletsViewModel: AccountWalletsViewModel
    @StateObject var accountPaymentsViewModel: AccountPaymentsViewModel
    @StateObject var payoutWalletViewModel: PayoutWalletViewModel
    
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
        _accountWalletsViewModel = StateObject.init(wrappedValue: AccountWalletsViewModel(
                api: api
            )
        )
        _accountPaymentsViewModel = StateObject.init(wrappedValue: AccountPaymentsViewModel(
                api: api
            )
        )
        
        _payoutWalletViewModel = StateObject.init(wrappedValue: PayoutWalletViewModel(
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
                    
                case .wallets:
                    WalletsView(
                        // wallets: accountWalletsViewModel.wallets,
                        payoutWalletId: payoutWalletViewModel.payoutWalletId,
                        navigate: viewModel.navigate,
                        api: api
                    )
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("Payout Wallets")
                                    .font(themeManager.currentTheme.toolbarTitleFont).fontWeight(.bold)
                            }
                        }
                        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
                        .environmentObject(accountPaymentsViewModel)
                        .environmentObject(accountWalletsViewModel)
                    
                case .wallet(let wallet):
                    
                    let payments = accountPaymentsViewModel.filterPaymentsByWalletId(wallet.walletId)
                
                    WalletView(
                        wallet: wallet,
                        payoutWalletId: payoutWalletViewModel.payoutWalletId,
                        payments: payments,
                        promptRemoveWallet: accountWalletsViewModel.promptRemoveWallet
                    )
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("\(wallet.blockchain) Wallet")
                                    .font(themeManager.currentTheme.toolbarTitleFont).fontWeight(.bold)
                            }
                        }
                        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
                        .environmentObject(accountPaymentsViewModel)
                
                }
            }
        }
        .confirmationDialog(
            "Are you sure you want to remove this wallet?",
            isPresented: $accountWalletsViewModel.isPresentingRemoveWalletSheet
        ) {
            Button("Remove wallet", role: .destructive) {
                removeWallet()
            }
        }
    }
    
    private func removeWallet() {
        
        viewModel.back()
        
        Task {
            let result = await accountWalletsViewModel.removeWallet()
            
            if case .failure(let error) = result {
                
                // TODO: snackbar error
                
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
