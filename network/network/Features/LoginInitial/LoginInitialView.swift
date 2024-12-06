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
            
            ScrollView(.vertical) {
                
                VStack {
                    
                    LoginCarousel()
                    
                    Spacer().frame(height: 32)
                    
                    UrTextField(
                        text: $viewModel.userAuth,
                        label: "Email or phone",
                        placeholder: "Enter your phone number or email",
                        onTextChange: { newValue in
                            // Filter whitespace
                            if newValue.contains(" ") {
                                viewModel.userAuth = newValue.filter { !$0.isWhitespace }
                            }
                        },
                        keyboardType: .emailAddress,
                        submitLabel: .continue,
                        onSubmit: {
                         
                            Task {
                                await getStarted()
                            }
                            
                        }
                    )
                    
                    Spacer()
                        .frame(height: 32)
                    
                    UrButton(
                        text: "Get started",
                        onClick: {
                            Task {
                                await getStarted()
                            }
                        },
                        enabled: viewModel.isValidUserAuth && !viewModel.isCheckingUserAuth
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
            }
        }
        
    }
    
    private func handleAppleLoginResult(_ result: Result<ASAuthorization, any Error>) async {
        let result = await viewModel.handleAppleLoginResult(result)
        await handleAuthLoginResult(result)
    }
    
    private func getStarted() async {
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
            // TODO: toast alert
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
        .background(Color.white)
        .clipShape(Capsule())
        
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
