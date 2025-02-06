//
//  WalletView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/15.
//

import SwiftUI
import URnetworkSdk

struct WalletView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var payoutWalletViewModel: PayoutWalletViewModel
    @EnvironmentObject var snackbarManager: UrSnackbarManager
    
    var wallet: SdkAccountWallet
    let isPayoutWallet: Bool
    let payments: [SdkAccountPayment]
    let promptRemoveWallet: (SdkId) -> Void
    let fetchPayments: () async -> Void
    
    var walletName: String {
        
        if wallet.blockchain == "SOL" {
            return "Solana"
        }
        
        // otherwise, POLY
        return "Polygon"
        
    }
    
    init(
        wallet: SdkAccountWallet,
        payoutWalletId: SdkId?,
        payments: [SdkAccountPayment],
        promptRemoveWallet: @escaping (SdkId) -> Void,
        fetchPayments: @escaping () async -> Void
    ) {
        self.wallet = wallet
        self.isPayoutWallet = payoutWalletId?.cmp(wallet.walletId) == 0
        self.payments = payments
        self.promptRemoveWallet = promptRemoveWallet
        self.fetchPayments = fetchPayments
    }
    
    var body: some View {
        ScrollView {
         
            VStack {
                
                HStack {
                    
                    VStack(alignment: .leading) {
                        WalletIcon(
                            blockchain: wallet.blockchain
                        )
                    }
                    
                    Spacer().frame(width: 16)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text("\(walletName) wallet")
                            .font(themeManager.currentTheme.secondaryTitleFont)
                            .foregroundColor(themeManager.currentTheme.textColor)
                        
                        HStack {
                            
                            Text("***\(String(wallet.walletAddress.suffix(6)))")
                                .font(themeManager.currentTheme.toolbarTitleFont)
                                .foregroundColor(themeManager.currentTheme.textColor)
                            
                            Spacer()

                            PayoutWalletTag(isPayoutWallet: isPayoutWallet)
                            
                        }
                        
                    }
                    
                    Spacer()
                    
                }
                
                Spacer().frame(height: 16)
                
                /**
                 * Actions
                 */
                VStack {
                    
                    if !isPayoutWallet {
                        
                        UrButton(text: "Make default", action: {
                            makeDefaultWallet()
                        })
                        
                        Spacer().frame(height: 8)
                        
                    }
                        
                    UrButton(
                        text: "Remove wallet",
                        action: {
                            
                            guard let walletId = wallet.walletId else {
                                
                                // TODO: snackbar error
                                
                                return
                            }
                            
                            promptRemoveWallet(walletId)
                        },
                        style: .outlineSecondary
                    )
                        
                }
                    
                Spacer().frame(height: 32)
                
                /**
                 * Payouts list
                 */
                PaymentsList(
                    payments: payments
                )
                
                Spacer()
                
            }
            .padding()
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
            
        }
        .refreshable {
            await fetchPayments()
        }
    }
    
    private func makeDefaultWallet() {
        
        guard let walletId = wallet.walletId else {
            snackbarManager.showSnackbar(message: "Error setting default wallet")
            
            return
        }
        
        Task {
            await payoutWalletViewModel.updatePayoutWallet(walletId)
            snackbarManager.showSnackbar(message: "Payout wallet updated")
        }
    }
}

#Preview {
    WalletView(
        wallet: SdkAccountWallet(),
        payoutWalletId: nil,
        payments: [],
        promptRemoveWallet: {_ in},
        fetchPayments: {}
    )
}
