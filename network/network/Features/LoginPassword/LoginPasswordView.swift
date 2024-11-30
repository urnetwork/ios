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
    
    var userAuth: String
    var navigate: (LoginInitialNavigationPath) -> Void

    var body: some View {
        
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack {
                    Text("It's nice to see you again")
                        .foregroundColor(.urWhite)
                        .font(themeManager.currentTheme.titleFont)
                    
                    Spacer().frame(height: 64)
                    
                    UrTextField(
                        text: .constant(userAuth),
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
                        onSubmit: {
                            Task {
                                await viewModel.login(userAuth: self.userAuth)
                            }
                        },
                        isSecure: true
                    )
                    
                    Spacer().frame(height: 32)
                    
                    UrButton(
                        text: "Continue",
                        onClick: {
                            Task {
                                let result = await viewModel.login(userAuth: self.userAuth)
                            }
                        }
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
    
    private func handleLoginResult(_ result: LoginNetworkResult) {
        switch result {
            
            case .successWithJwt(let jwt):
                break
            case .successWithVerificationRequired:
                navigate(.verify(userAuth))
                break
            case .failure(let error):
                print("CreateNetworkView: handleResult: \(error.localizedDescription)")
                break
            
        }
    }
    
}

#Preview {
    LoginPasswordView(
        userAuth: "hello@ur.io",
        navigate: {_ in }
    )
    .environmentObject(ThemeManager.shared)
}
