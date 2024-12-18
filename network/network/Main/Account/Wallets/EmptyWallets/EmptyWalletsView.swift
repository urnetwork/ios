//
//  EmptyWalletsView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/17.
//

import SwiftUI
import URnetworkSdk

struct EmptyWalletsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var displayExternalWalletSheet: Bool
    var fetchAccountWallets: () -> Void
    var api: SdkBringYourApi?
    
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
                action: {
                    displayExternalWalletSheet = true
                },
                style: .outlineSecondary
            )
        }
    }
}

#Preview {
    EmptyWalletsView(
        displayExternalWalletSheet: .constant(false),
        fetchAccountWallets: {}
    )
}
