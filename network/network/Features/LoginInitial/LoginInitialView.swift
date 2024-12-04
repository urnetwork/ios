//
//  LoginInitialView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/20.
//

import SwiftUI
import URnetworkSdk
import AuthenticationServices

struct LoginInitialView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel: ViewModel
    
    var api: SdkBringYourApi?
    var navigate: (LoginInitialNavigationPath) -> Void
    
    init(api: SdkBringYourApi?, navigate: @escaping (LoginInitialNavigationPath) -> Void) {
        _viewModel = StateObject(wrappedValue: ViewModel(api: api))
        self.navigate = navigate
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
        handleAuthLoginResult(result)
    }
    
    private func getStarted() async {
        let result = await viewModel.getStarted()
        handleAuthLoginResult(result)
    }
    
    private func handleAuthLoginResult(_ authLoginResult: AuthLoginResult) {
        
        print("handleAuthLoginResult")
        
        switch authLoginResult {
            
            case .login(let loginResult):
                print("navigate to login")
                // navigate(.password(viewModel.userAuth))
                navigate(.password(loginResult.userAuth))
                break
            
            case .create:
                print("navigate to create")
                // TODO: params need to be changed to SdkAuthLoginArgs
                navigate(.createNetwork(viewModel.userAuth))
                break
            
            case .failure(let error):
                print("auth login error: \(error.localizedDescription)")
                break
            
        }
    }
}

#Preview {
    ZStack {
        LoginInitialView(
            api: nil,
            navigate: {_ in }
        )
    }
    .environmentObject(ThemeManager.shared)
    .background(ThemeManager.shared.currentTheme.backgroundColor)
}
