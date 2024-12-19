//
//  PaymentsList.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/19.
//

import SwiftUI
import URnetworkSdk

struct PaymentsList: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    var payments: [SdkAccountPayment]
    
    var body: some View {
        
        VStack {
            
            if !payments.isEmpty {
             
                HStack {
                    Text("Earnings")
                        .font(themeManager.currentTheme.bodyFont)
                        .foregroundColor(themeManager.currentTheme.textColor)
                        
                    
                    Spacer()
                }
                
                ForEach(payments, id: \.paymentId) { payment in
                    
                    HStack {
                        
                        Image("ur.symbols.check.circle")
                            .foregroundColor(themeManager.currentTheme.textMutedColor)
                            .frame(width: 48, height: 48)
                            .background(themeManager.currentTheme.tintedBackgroundBase)
                            .clipShape(Circle())
                        
                        Spacer().frame(width: 16)
                        
                        VStack {
                            
                            HStack {
                                Text("+\(String(format: "%.2f", payment.tokenAmount)) USDC")
                                    .font(themeManager.currentTheme.bodyFont)
                                    .foregroundColor(themeManager.currentTheme.textColor)
                                
                                Spacer()
                            }
                                
                            
                            HStack {
                                if let completeTime = payment.completeTime {
                                    Text(completeTime.format("Jan 2"))
                                        .font(themeManager.currentTheme.secondaryBodyFont)
                                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                                } else {
                                    Text("Pending")
                                        .font(themeManager.currentTheme.secondaryBodyFont)
                                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                                }
                                
                                Spacer()
                            }
                            
                        }
                        
                        Spacer()
                        
                        Text("***\(payment.walletAddress.suffix(6))")
                            .font(themeManager.currentTheme.secondaryBodyFont)
                            .foregroundColor(themeManager.currentTheme.textMutedColor)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
}

#Preview {
    PaymentsList(
        payments: []
    )
}
