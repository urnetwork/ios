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
    
    var wallets: [SdkAccountWallet] = []
    var navigate: (AccountNavigationPath) -> Void
    var createWallet: () -> Void
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
            
            Spacer().frame(height: 16)
            
            if (wallets.isEmpty) {
                EmptyWalletsView()
            }
            
            Spacer()
            
            
                
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct EmptyWalletsView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
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
            
            Spacer()
            
            UrButton(
                text: "Set up Circle wallet", action: {}
            )
            
            Spacer().frame(height: 16)
            
            UrButton(
                text: "Connect external wallet",
                action: {},
                style: .outlineSecondary
            )
        
            
        }
    }
    
}

#Preview {
    
    let themeManager = ThemeManager.shared
    
    WalletsView(
        navigate: {_ in},
        createWallet: {},
        unpaidMegaBytes: "1.23"
    )
        .environmentObject(themeManager)
        .background(themeManager.currentTheme.backgroundColor)
}
