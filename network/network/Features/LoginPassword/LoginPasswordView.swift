//
//  LoginPasswordView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import SwiftUI

struct LoginPasswordView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var userAuth: String
    
    var body: some View {
        VStack {
            Text("Login password screen")
                .foregroundColor(.urWhite)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .applySystemBackground()
    }
}

#Preview {
    LoginPasswordView(
        userAuth: "hello@ur.io"
    )
    .environmentObject(ThemeManager.shared)
}
