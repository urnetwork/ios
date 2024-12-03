//
//  LoginPasswordView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import SwiftUI
import URnetworkSdk

struct LoginPasswordView: View {
    
    @EnvironmentObject var networkSpaceStore: NetworkSpaceStore
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel: ViewModel
    
    var userAuth: String
    var navigate: (LoginInitialNavigationPath) -> Void
    var authenticateNetworkClient: (String) async -> Result<Void, Error>
    
    init(
        userAuth: String,
        navigate: @escaping (LoginInitialNavigationPath) -> Void,
        authenticateNetworkClient: @escaping (String) async -> Result<Void, Error>,
        api: SdkBringYourApi?
    ) {
        _viewModel = StateObject(wrappedValue: ViewModel(api: api))
        self.userAuth = userAuth
        self.navigate = navigate
        self.authenticateNetworkClient = authenticateNetworkClient
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
                                await handleLoginResult(result)
                            }
                        },
                        enabled: !viewModel.isLoggingIn && viewModel.isValid
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
    
    private func handleLoginResult(_ result: LoginNetworkResult) async {
        switch result {
            
            case .successWithJwt(let jwt):
                await handleSuccessWithJwt(jwt)
                break
            case .successWithVerificationRequired:
                navigate(.verify(userAuth))
                viewModel.setIsLoggingIn(false)
            
                break
            case .failure(let error):
                print("CreateNetworkView: handleResult: \(error.localizedDescription)")
                viewModel.setIsLoggingIn(false)
                // TODO: toast alert
                // TODO: clear viewmodel loading state
                break
            
        }
    }
    
    private func handleSuccessWithJwt(_ jwt: String) async {
        let result = await authenticateNetworkClient(jwt)
        
        if case .failure(let error) = result {
            print("CreateNetworkView: handleSuccessWithJwt: \(error.localizedDescription)")
            // TODO: toast alert
            // TODO: clear viewmodel loading state
        }
        viewModel.setIsLoggingIn(false)
        
    }
    
}

#Preview {
    LoginPasswordView(
        userAuth: "hello@ur.io",
        navigate: {_ in },
        authenticateNetworkClient: {_ in
            return .success(())
        },
        api: nil
    )
    .environmentObject(ThemeManager.shared)
}
