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
    
    @Binding var presentConnectWalletSheet: Bool
    
    @StateObject var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        VStack {
            
            VStack {
                
                Spacer().frame(height: 16)
                
                HStack {
                    Text("You share with others, we share with you. Earn a share of revenue when you provide data to others in the network.")

                    Spacer()
                }
                
                Spacer().frame(height: 16)
                
                HStack {
                    Text("To start earning, connect your Solana wallet to URnetwork.")
                    
                    Spacer()
                }
                
            }
            .font(themeManager.currentTheme.secondaryBodyFont)
            .foregroundColor(themeManager.currentTheme.textMutedColor)
            
            Spacer()
            
            UrButton(text: "Connect Wallet", action: {
                presentConnectWalletSheet = true
            })
            
            Spacer().frame(height: 16)
            
        }
        .padding(.horizontal)
    }
    
}

#Preview {
    EmptyWalletsView(
        presentConnectWalletSheet: .constant(false)
    )
}
