//
//  ConnectWalletSheetView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/09.
//

import SwiftUI

struct ConnectWalletSheetView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var connectWalletProviderViewModel: ConnectWalletProviderViewModel
    
    var navigate: (ConnectWalletNavigationPath) -> Void
    
    var body: some View {
        VStack {

            HStack(spacing: 12) {
                
                Button(action: {
                    connectWalletProviderViewModel.connectPhantomWallet()
                }) {
                    
                    VStack {
                        Image("phantom.white.logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .padding()
                            .background(Color(hex: "#ab9ff2"))
                            .cornerRadius(12)
                        

                        Text("Phantom")
                            .font(themeManager.currentTheme.secondaryBodyFont)
                            .foregroundColor(themeManager.currentTheme.textColor)
                    }
                    
                }
                
                Button(action: {
                    connectWalletProviderViewModel.connectSolflareWallet()
                }) {
                    
                    VStack {
                        Image("solflare.logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .padding()
                            .background(.urWhite)
                            .cornerRadius(12)
                        

                        Text("Solflare")
                            .font(themeManager.currentTheme.secondaryBodyFont)
                            .foregroundColor(themeManager.currentTheme.textColor)
                    }
                    
                }
                
                Button(action: {
                    navigate(ConnectWalletNavigationPath.external)
                }) {
                    
                    VStack {
                        Image("ur.symbols.wallet")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .padding()
                            .background(.urLightBlue)
                            .cornerRadius(12)
                        

                        Text("Other")
                            .font(themeManager.currentTheme.secondaryBodyFont)
                            .foregroundColor(themeManager.currentTheme.textColor)
                    }
                    
                }
                
            }
            
            Spacer().frame(height: 16)
            
            HStack {
                Text("These wallets are not affiliated or controlled by URnetwork. We will send earnings into the connected wallet.")
                    .font(themeManager.currentTheme.secondaryBodyFont)
                    .foregroundColor(themeManager.currentTheme.textMutedColor)
            }
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Connect external wallet")
                    .font(themeManager.currentTheme.toolbarTitleFont).fontWeight(.bold)
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .padding(.horizontal)
    }
}

#Preview {
    
    let themeManager = ThemeManager.shared
    
    VStack {
        ConnectWalletSheetView(
            navigate: {_ in }
        )
    }
    .environmentObject(themeManager)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(themeManager.currentTheme.backgroundColor)
        
}
