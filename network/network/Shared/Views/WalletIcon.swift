//
//  WalletIcon.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/19.
//

import SwiftUI

struct WalletIcon: View {
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
    WalletIcon(
        isCircleWallet: false,
        blockchain: "SOL"
    )
}
