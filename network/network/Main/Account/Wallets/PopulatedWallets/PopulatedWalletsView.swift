//
//  PopulatedWalletsView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/17.
//

import SwiftUI
import URnetworkSdk

struct PopulatedWalletsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var accountPaymentsViewModel: AccountPaymentsViewModel
    
    var wallets: [SdkAccountWallet]
    var payoutWalletId: SdkId?
    @Binding var displayExternalWalletSheet: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                
                Text("Wallets")
                    .foregroundColor(themeManager.currentTheme.textColor)
                    .font(themeManager.currentTheme.bodyFont)
                
                Spacer()
                
                Button(action: {
                    displayExternalWalletSheet = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                        .frame(width: 26, height: 26)
                        .background(themeManager.currentTheme.tintedBackgroundBase)
                        .clipShape(Circle())
                }
                
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                // TODO: investigate why using LazyHStack causes the app to freeze with CPU 100% when lifting ForEach contents into a separate view
                // NOTE: changing LazyHStack -> HStack, moving the ForEach content into a separate view works
                // LazyHStack {
                HStack(spacing: 16) {
                    ForEach(wallets, id: \.walletId) { wallet in
                        
                        WalletListItem(
                            wallet: wallet,
                            payoutWalletId: payoutWalletId
                        )
                        
                    }
                }
                .padding()
                
            }
            
            Spacer()

        }

    }
}

private struct WalletListItem: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var accountPaymentsViewModel: AccountPaymentsViewModel
    
    var wallet: SdkAccountWallet
    var payoutWalletId: SdkId?
    
    var body: some View {
        let isCircleWallet = wallet.walletType == SdkWalletTypeCircleUserControlled
        let isPayoutWallet = payoutWalletId?.cmp(wallet.walletId) == 0
        
        VStack {
            
            HStack {
                
                VStack {
                    WalletChainIcon(isCircleWallet: isCircleWallet, blockchain: wallet.blockchain)
                    Spacer()
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                 
                    HStack {
                        Text(isPayoutWallet ? "DEFAULT" : "")
                            .font(Font.custom("PP NeueBit", size: 16).weight(.bold))
                            .foregroundColor(themeManager.currentTheme.textMutedColor)
                    }
                    .padding(6)
                    .background(isPayoutWallet ? .white.opacity(0.04) : .clear)
                    .cornerRadius(6)
                    
                    
                    Spacer().frame(height: 8)
                    
                    VStack(spacing: 0) {
                        
                        HStack {
                            
                            Spacer()
                            
                            Text(
                                "\(String(format: "%.2f", accountPaymentsViewModel.totalPaymentsByWalletId(wallet.walletId))) USDC"
                            )
                                .foregroundColor(themeManager.currentTheme.textColor)
                                .font(Font.custom("ABCGravity-ExtraCondensed", size: 24))
                        }
                        
                        HStack {
                            Spacer()
                            
                            Text("total payouts")
                                .font(themeManager.currentTheme.secondaryBodyFont)
                                .foregroundColor(themeManager.currentTheme.textMutedColor)
                                .padding(.top, -4)
                        }
                        
                    }
                    
                }
                
            }
            
            Spacer()
            
            HStack(alignment: .center) {
                
                if isCircleWallet {
                    
                    Text("Circle")
                        .font(themeManager.currentTheme.secondaryBodyFont)
                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                    
                } else {
                    
                    Text(wallet.blockchain)
                        .font(themeManager.currentTheme.secondaryBodyFont)
                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                    
                }
                
                Spacer()
                
                Text(wallet.obscuredWalletAddress())
                    .font(Font.custom("PP NeueBit", size: 18))
                    .foregroundColor(themeManager.currentTheme.textColor)
                
            }
        }
        .padding()
        .frame(width: 240, height: 124)
        .background(themeManager.currentTheme.tintedBackgroundBase)
        .cornerRadius(12)
    }
    
}

private struct WalletChainIcon: View {
    
    var isCircleWallet: Bool
    var blockchain: String
    
    var backgroundGradient: Gradient {
        
        if isCircleWallet {
            return Gradient(colors: [Color(hex: "#68D7FA"), Color(hex: "#7EF1B3")])
        }
        
        if blockchain == "SOL" {
            return Gradient(colors: [Color(hex: "#9945FF"), Color(hex: "#14F195")])
        }
        
        // otherwise, POLY
        return Gradient(colors: [Color(hex: "#8A46FF"), Color(hex: "#6E38CC")])
    }
    
    var logoPath: String {
        
        if isCircleWallet {
            return "circle.logo"
        }
        
        if blockchain == "SOL" {
            return "solana.logo"
        }
        
        // otherwise, POLY
        return "polygon.logo"
        
    }
    
    var logoWidth: CGFloat {
        
        if isCircleWallet {
            return 24
        }
        
        if blockchain == "SOL" {
            return 24
        }
        
        // otherwise, POLY
        return 48
        
    }
    
    var body: some View {
        
        ZStack {
            LinearGradient(gradient: backgroundGradient, startPoint: .top, endPoint: .bottom)
                .clipShape(
                    Circle()
                )
            
            Image(logoPath)
                .resizable()
                .scaledToFit()
                .frame(width: logoWidth, height: logoWidth)
        }
        .frame(width: 48, height: 48)

    }
    
}

#Preview {
    
    PopulatedWalletsView(
        wallets: [],
        payoutWalletId: nil,
        displayExternalWalletSheet: .constant(false)
    )
}
