//
//  LoginInitialFormView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/06.
//

import SwiftUI
import AuthenticationServices

struct LoginInitialFormView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @Binding var userAuth: String
    var handleUserAuth: () async -> Void
    var handleAppleLoginResult: (_ result: Result<ASAuthorization, any Error>) async -> Void
    var handleGoogleSignInButton: () async -> Void
    var isValidUserAuth: Bool
    var isCheckingUserAuth: Bool
    
    var body: some View {
        
        VStack {
         
            UrTextField(
                text: $userAuth,
                label: "Email or phone",
                placeholder: "Enter your phone number or email",
                onTextChange: { newValue in
                    // Filter whitespace
                    if newValue.contains(" ") {
                        userAuth = newValue.filter { !$0.isWhitespace }
                    }
                },
                keyboardType: .emailAddress,
                submitLabel: .continue,
                onSubmit: {
                 
                    Task {
                        await handleUserAuth()
                    }
                    
                }
            )
            
            Spacer()
                .frame(height: 32)
            
            UrButton(
                text: "Get started",
                onClick: {
                    Task {
                        await handleUserAuth()
                    }
                },
                enabled: isValidUserAuth && !isCheckingUserAuth
            )
            
            Spacer()
                .frame(height: 24)
            
            Text("or", comment: "Referring to the two options 'Get started' *or* 'Login with Apple'")
                .foregroundColor(themeManager.currentTheme.textMutedColor)
            
            Spacer()
                .frame(height: 24)
            
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.email]
            } onCompletion: { result in
                
                print("SignInWithAppleButton: onCompletion")
                
                Task {
                    await handleAppleLoginResult(result)
                }
            }
            .frame(height: 48)
            .clipShape(Capsule())
            .signInWithAppleButtonStyle(.white)
            
            Spacer()
                .frame(height: 24)
            
            UrGoogleSignInButton(
                action: handleGoogleSignInButton
            )
            
        }
        .frame(maxWidth: 400)
    }
}

struct LoginInitialFormView_Previews: PreviewProvider {
    @State var userAuth = ""

    static var previews: some View {
        LoginInitialFormView_PreviewsWrapper()
    }

    struct LoginInitialFormView_PreviewsWrapper: View {
        @State var userAuth = ""

        var body: some View {
            
            ZStack {
                LoginInitialFormView(
                    userAuth: $userAuth,
                    handleUserAuth: {},
                    handleAppleLoginResult: { _ in },
                    handleGoogleSignInButton: {},
                    isValidUserAuth: false,
                    isCheckingUserAuth: false
                )
            }
            .environmentObject(ThemeManager.shared)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.urBlack)
        }
    }
}
