//
//  LoginPasswordView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import SwiftUI

struct LoginPasswordView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = ViewModel()
    
    let userAuth: String
    
    @State private var emailOrPhone: String
    
    init(userAuth: String) {
        print("initialize user auth")
        self.userAuth = userAuth
        // Initialize the state with the passed value
        _emailOrPhone = State(initialValue: userAuth)
    }
    
    private var login = {
        
    }
    
    var body: some View {
        
        
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack {
                    Text("It's nice to see you again")
                        .foregroundColor(.urWhite)
                        .font(themeManager.currentTheme.titleFont)
                    
                    Spacer().frame(height: 64)
                    
                    UrTextField(
                        text: $emailOrPhone,
                        label: "Email or phone number",
                        placeholder: "Enter your phone number or email",
                        isEnabled: false
                    )
                    
                    Spacer().frame(height: 16)
                    
                    UrTextField(
                        text: $viewModel.password,
                        label: "Password",
                        placeholder: "************",
                        submitLabel: .continue,
                        onSubmit: login,
                        isSecure: true
                    )
                    
                    Spacer().frame(height: 32)
                    
                    UrButton(
                        text: "Continue",
                        onClick: login
                        // todo add icon
                    )
                    
                    Spacer().frame(height: 32)
                    
                    HStack {
                        Text("Forgot your password?")
                            .foregroundColor(themeManager.currentTheme.textMutedColor)
                        Text("Reset it.", comment: "Referring to resetting the password")
                            .foregroundColor(themeManager.currentTheme.textColor)
                    }
                    
                    
                }
                .padding()
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
            }
        }
    
    }
}

#Preview {
    LoginPasswordView(
        userAuth: "hello@ur.io"
    )
    .environmentObject(ThemeManager.shared)
}
