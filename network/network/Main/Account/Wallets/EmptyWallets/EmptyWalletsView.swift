//
//  EmptyWalletsView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/17.
//

import SwiftUI
import URnetworkSdk
import CryptoKit

struct EmptyWalletsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var accountWalletsViewModel: AccountWalletsViewModel
    
    @Binding var displayExternalWalletSheet: Bool
    
    @StateObject var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        VStack {
            
            VStack {
                
                HStack {
                    Text("You share with others, we share with you. Earn a share of revenue when you provide data to others in the network.")

                    Spacer()
                }
                
                Spacer().frame(height: 16)
                
                HStack {
                    Text("To start earning, connect your cryptocurrency wallet to URnetwork or set one up with Circle.")
                    
                    Spacer()
                }
                
            }
            .font(themeManager.currentTheme.secondaryBodyFont)
            .foregroundColor(themeManager.currentTheme.textMutedColor)
            
            Spacer().frame(height: 24)
            
            VStack {
                
                Spacer().frame(height: 8)
                
                // TODO: use Phantom icon
                UrButton(
                    text: "Link Phantom Wallet", action: {
                        viewModel.connectPhantomWallet()
                    }
                )
                
                Spacer().frame(height: 16)
            
                // TODO: use Solflare icon
                UrButton(
                    text: "Link Solflare Wallet", action: {
                        viewModel.connectSolflareWallet()
                    }
                )
                
                Spacer().frame(height: 16)
                
                UrButton(
                    text: "Connect external wallet",
                    action: {
                        displayExternalWalletSheet = true
                    },
                    style: .outlineSecondary
                )
                
            }
            
        }
        .onAppear {
            viewModel.createKeyPair()
        }
        .onReceive(viewModel.$connectedPublicKey) { walletAddress in
            
            if let walletAddress = walletAddress {
                
                // TODO: check if wallet address already present in existing wallets
                
                Task {
                    await accountWalletsViewModel.connectWallet(walletAddress: walletAddress, chain: WalletChain.sol)
                }
                
            }
            
        }
        .onOpenURL { url in
            viewModel.handleDeepLink(url)
        }
    }
    
}

#Preview {
    EmptyWalletsView(
        displayExternalWalletSheet: .constant(false)
    )
}
