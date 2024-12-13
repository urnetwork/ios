//
//  LoginInitialView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/20.
//

import SwiftUI
import URnetworkSdk
import AuthenticationServices
import GoogleSignInSwift
import GoogleSignIn

struct LoginInitialView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var snackbarManager: UrSnackbarManager
    @StateObject private var viewModel: ViewModel
    
    var api: SdkBringYourApi?
    var navigate: (LoginInitialNavigationPath) -> Void
    var authenticateNetworkClient: (String) async -> Result<Void, Error>
    
    init(
        api: SdkBringYourApi?,
        navigate: @escaping (LoginInitialNavigationPath) -> Void,
        authenticateNetworkClient: @escaping (String) async -> Result<Void, Error>
    ) {
        _viewModel = StateObject(wrappedValue: ViewModel(api: api))
        self.navigate = navigate
        self.authenticateNetworkClient = authenticateNetworkClient
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let isLandscape = geometry.size.width > geometry.size.height
            let isTablet = UIDevice.current.userInterfaceIdiom == .pad
      
            ScrollView(.vertical) {
                
                if isLandscape && isTablet {
                    
                    HStack(alignment: .center) {
                        
                        LoginCarousel()
                            .frame(width: geometry.size.width / 2)
                        
                        LoginInitialFormView(
                            userAuth: $viewModel.userAuth,
                            handleUserAuth: handleUserAuth,
                            handleAppleLoginResult: handleAppleLoginResult,
                            handleGoogleSignInButton: handleGoogleSignInButton,
                            isValidUserAuth: viewModel.isValidUserAuth,
                            isCheckingUserAuth: viewModel.isCheckingUserAuth
                        )
                        .frame(width: geometry.size.width / 2, alignment: .leading)
                        
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center) // Fill the height and center content
                    
                } else {
                
                    VStack {
                        
                        LoginCarousel()
                        
                        Spacer().frame(height: 64)
                        
                        LoginInitialFormView(
                            userAuth: $viewModel.userAuth,
                            handleUserAuth: handleUserAuth,
                            handleAppleLoginResult: handleAppleLoginResult,
                            handleGoogleSignInButton: handleGoogleSignInButton,
                            isValidUserAuth: viewModel.isValidUserAuth,
                            isCheckingUserAuth: viewModel.isCheckingUserAuth
                        )
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    .frame(minHeight: geometry.size.height)
                    .frame(maxWidth: .infinity)
                    
                }
                
            }
        }
        
    }
    
    private func handleAppleLoginResult(_ result: Result<ASAuthorization, any Error>) async {
        let result = await viewModel.handleAppleLoginResult(result)
        await handleAuthLoginResult(result)
    }
    
    private func handleUserAuth() async {
        let result = await viewModel.getStarted()
        await handleAuthLoginResult(result)
    }
    
    private func handleAuthLoginResult(_ authLoginResult: AuthLoginResult) async {
        
        switch authLoginResult {
            
        case .login(let authJwt):
            await handleSuccessWithJwt(authJwt)
            
            break
            
        case .promptPassword(let loginResult):
            navigate(.password(loginResult.userAuth))
            break
            
        case .create(let authLoginArgs):
            navigate(.createNetwork(authLoginArgs))
            break
        
        case .failure(let error):
            print("auth login error: \(error.localizedDescription)")
            break
            
        }
    }
    
    private func handleSuccessWithJwt(_ jwt: String) async {
        let result = await authenticateNetworkClient(jwt)
        
        if case .failure(let error) = result {
            print("[LoginInitialView] handleSuccessWithJwt: \(error.localizedDescription)")
            
            snackbarManager.showSnackbar(message: "There was an error authenticating, please try again later.")
            
            // TODO: clear viewmodel loading state
            
        }
        
    }
    
    private func handleGoogleSignInButton() async {
        
        guard let rootViewController = getRootViewController() else {
            print("no root view controller found")
            return
        }
        
        do {
            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            let result = await viewModel.handleGoogleLoginResult(signInResult)
            await handleAuthLoginResult(result)
            
         } catch {
             print("Error signing in: \(error.localizedDescription)")
         }
        
    }
    
}

private struct LoginInitialFormView: View {
    
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
                action: {
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

#Preview {
    ZStack {
        LoginInitialView(
            api: nil,
            navigate: {_ in },
            authenticateNetworkClient: {_ in
                return .success(())
            }
        )
    }
    .environmentObject(ThemeManager.shared)
    .background(ThemeManager.shared.currentTheme.backgroundColor)
}
