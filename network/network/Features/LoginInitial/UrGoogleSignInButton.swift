//
//  UrGoogleSignInButton.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/06.
//

import SwiftUI

struct UrGoogleSignInButton: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var action: () async -> Void
    
    var body: some View {
        
        return Button(action: {
            Task {
                await action()
            }
        }) {
            HStack(alignment: .center) {
                
                Image("GoogleIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                
                Text("Sign in with Google")
                    .foregroundColor(themeManager.currentTheme.inverseTextColor)
                        .font(
                            Font.system(size: 19, weight: .medium)
                        )
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 48)
        .background(Color.urLightBlue)
        .clipShape(Capsule())
        
    }
    
}
