//
//  WalletsRootView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/15.
//

import SwiftUI
import URnetworkSdk

struct WalletsView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var accountPaymentsViewModel: AccountPaymentsViewModel
    @EnvironmentObject var accountWalletsViewModel: AccountWalletsViewModel
    @EnvironmentObject var payoutWalletViewModel: PayoutWalletViewModel
    
    var navigate: (AccountNavigationPath) -> Void
    var api: SdkApi?
    
    @StateObject private var viewModel: ViewModel = ViewModel()
    @StateObject private var connectWalletProviderViewModel = ConnectWalletProviderViewModel()
    
    var body: some View {
        
        Group {
         
            if (accountWalletsViewModel.wallets.isEmpty) {
                /**
                 * Empty wallet view
                 */
                VStack {
                    
                    WalletsHeader(
                        unpaidMegaBytes: accountWalletsViewModel.unpaidMegaBytes
                    )
                    
                    EmptyWalletsView(
                        presentConnectWalletSheet: $viewModel.presentConnectWalletSheet
                    )
        
                }
            } else {
                
                /**
                 * Populated wallets view
                 */
                
                ScrollView {
                 
                    VStack {
                        
                        WalletsHeader(
                            unpaidMegaBytes: accountWalletsViewModel.unpaidMegaBytes
                        )
                        
                        PopulatedWalletsView(
                            navigate: navigate,
                            presentConnectWalletSheet: $viewModel.presentConnectWalletSheet
                        )
                    }
                    
                }
                .refreshable {
                    async let fetchWallets: Void = accountWalletsViewModel.fetchAccountWallets()
                    async let fetchPayments: Void = accountPaymentsViewModel.fetchPayments()
                    async let fetchTransferStats: Void = accountWalletsViewModel.fetchTransferStats()
                    
                    // Wait for all tasks to complete
                    (_, _, _) = await (fetchWallets, fetchPayments, fetchTransferStats)
                }
                
            }
            
        }
        .onReceive(connectWalletProviderViewModel.$connectedPublicKey) { walletAddress in
            
            /**
             * Once we receive an address from the wallet, here we associate the address with the network
             */
            
            if let walletAddress = walletAddress {
                
                // TODO: check if wallet address already present in existing wallets
                
                Task {
                    // TODO: error handling on connect wallet
                    let _ = await accountWalletsViewModel.connectWallet(walletAddress: walletAddress, chain: WalletChain.sol)
                    await payoutWalletViewModel.fetchPayoutWallet()
                    viewModel.presentConnectWalletSheet = false
                }
                
            }
            
        }
        .onOpenURL { url in
            connectWalletProviderViewModel.handleDeepLink(url)
        }
        .sheet(isPresented: $viewModel.presentConnectWalletSheet) {
            
            ConnectWalletNavigationStack(
                api: api,
                presentConnectWalletSheet: $viewModel.presentConnectWalletSheet
            )
            .presentationDetents([.height(264)])
        }
        .environmentObject(connectWalletProviderViewModel)
    }
}

struct WalletsHeader: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var unpaidMegaBytes: String
    
    var body: some View {
        VStack {
         
            HStack {
                Text("URwallet")
                    .font(themeManager.currentTheme.titleFont)
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                Spacer()
            }
            
            Spacer().frame(height: 16)
            
            VStack {
                HStack {
                    UrLabel(text: "Unpaid megabytes provided")
                    Spacer()
                }
                
                HStack {
                    Text(unpaidMegaBytes)
                        .font(themeManager.currentTheme.titleCondensedFont)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    Spacer()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(themeManager.currentTheme.tintedBackgroundBase)
            .cornerRadius(12)
            
            Spacer().frame(height: 8)
            
            HStack {
                Text("Payouts occur every two weeks, and require a minimum amount to receive a payout.")
                    .font(themeManager.currentTheme.secondaryBodyFont)
                    .foregroundColor(themeManager.currentTheme.textMutedColor)
                
                Spacer()
            }
            
        }
        .padding(.horizontal)
    }
}

#Preview {
    
    let themeManager = ThemeManager.shared
    
    WalletsView(
        navigate: {_ in}
    )
        .environmentObject(themeManager)
        .background(themeManager.currentTheme.backgroundColor)
}
