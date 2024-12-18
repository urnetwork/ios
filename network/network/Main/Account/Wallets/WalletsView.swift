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
    
    var wallets: [SdkAccountWallet]
    var payoutWalletId: SdkId?
    var navigate: (AccountNavigationPath) -> Void
    var unpaidMegaBytes: String
    // var payouts: [SdkAccountPayment]
    var fetchAccountWallets: () async -> Void
    var fetchTransferStats: () async -> Void
    var api: SdkBringYourApi?
    
    @StateObject private var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        
        ScrollView {
         
            VStack {
                
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
                .padding()
                
                Spacer().frame(height: 16)
                
                if (wallets.isEmpty) {
                    EmptyWalletsView(
                        displayExternalWalletSheet: $viewModel.displayExternalWalletSheet,
                        api: api
                    )
                    .padding()
                } else {
                    PopulatedWalletsView(
                        wallets: wallets,
                        payoutWalletId: payoutWalletId,
                        displayExternalWalletSheet: $viewModel.displayExternalWalletSheet
                    )
                }
                
                Spacer()
                
            }
            
        }
        .refreshable {
            async let fetchWallets: Void = fetchAccountWallets()
            async let fetchPayments: Void = accountPaymentsViewModel.fetchPayments()
            async let fetchTransferStats: Void = fetchTransferStats()
            
            // Wait for all tasks to complete
            (_, _, _) = await (fetchWallets, fetchPayments, fetchTransferStats)
        }
        // .frame(maxWidth: .infinity, maxHeight: .infinity)
        // .frame(maxHeight: .infinity)
        // connect external wallet bottom sheet
        .sheet(isPresented: $viewModel.displayExternalWalletSheet) {
            
            ConnectExternalWalletSheetView(
                onSuccess: {
                    Task {
                        await fetchAccountWallets()
                        viewModel.displayExternalWalletSheet = false
                    }
                },
                api: api
            )
            .presentationDetents([.height(264)])
            .presentationDragIndicator(.visible)
            
        }
    }
}

#Preview {
    
    let themeManager = ThemeManager.shared
    
    WalletsView(
        wallets: [],
        payoutWalletId: nil,
        navigate: {_ in},
        unpaidMegaBytes: "1.23",
        // payouts: [],
        fetchAccountWallets: {},
        fetchTransferStats: {}
    )
        .environmentObject(themeManager)
        .background(themeManager.currentTheme.backgroundColor)
}
