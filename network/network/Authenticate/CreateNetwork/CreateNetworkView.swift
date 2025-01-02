//
//  CreateNetworkView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import SwiftUI
import URnetworkSdk

struct CreateNetworkView: View {

    var authLoginArgs: SdkAuthLoginArgs
    var navigate: (LoginInitialNavigationPath) -> Void
    
    var userAuth: String?
    var authJwt: String?
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var snackbarManager: UrSnackbarManager
    @EnvironmentObject var deviceManager: DeviceManager
    
    @StateObject private var viewModel: ViewModel
    
    @FocusState private var focusedField: Field?
    
    init(
        authLoginArgs: SdkAuthLoginArgs,
        navigate: @escaping (LoginInitialNavigationPath) -> Void,
        // authenticateNetworkClient: @escaping (String) async -> Result<Void, Error>,
        api: SdkBringYourApi
    ) {
        
        var authType: AuthType = .password
        
        if authLoginArgs.authJwtType == "apple" {
            authType = AuthType.apple
        }
        
        _viewModel = StateObject.init(wrappedValue: ViewModel(
            api: api,
            authType: authType
        ))
        
        self.authLoginArgs = authLoginArgs
        // self.authenticateNetworkClient = authenticateNetworkClient
        
        if !authLoginArgs.userAuth.isEmpty {
            self.userAuth = authLoginArgs.userAuth
        } else {
            self.userAuth = nil
        }
        
        if authLoginArgs.authJwtType == "apple" && !authLoginArgs.authJwt.isEmpty {
            self.authJwt = authLoginArgs.authJwt
        } else {
            self.authJwt = nil
        }
        
        self.navigate = navigate
    }

    enum Field {
        case networkName, password
    }
    
    var body: some View {

        GeometryReader { geometry in
            
            ScrollView(.vertical) {
                VStack(alignment: .center) {
                    Text("Join URnetwork", comment: "URnetwork is the project name and should not be translated")
                        .foregroundColor(.urWhite)
                        .font(themeManager.currentTheme.titleFont)
                    
                    Spacer().frame(height: 48)
                    
                    if let userAuth = userAuth {
                        
                        UrTextField(
                            // text: $viewModel.userAuth,
                            text: .constant(userAuth),
                            label: "Email or phone number",
                            placeholder: "Enter your phone number or email",
                            isEnabled: false,
                            keyboardType: .emailAddress,
                            submitLabel: .next
                        )
                        
                        Spacer().frame(height: 24)
                        
                    }
                    
                    UrTextField(
                        text: $viewModel.networkName,
                        label: "Network name",
                        placeholder: "Enter a name for your network",
                        supportingText: viewModel.networkNameSupportingText,
                        validationState: viewModel.networkNameValidationState,
                        submitLabel: .next,
                        disableCapitalization: true
                    )
                    .focused($focusedField, equals: .networkName)
                    .onSubmit {
                        
                        if (userAuth != nil) {
                            focusedField = .password
                        }
                        
                    }
                    
                    if (userAuth != nil) {
                        
                        Spacer().frame(height: 24)
                        
                        UrTextField(
                            text: $viewModel.password,
                            label: "Password",
                            placeholder: "************",
                            supportingText: "Password must be at least 12 characters long",
                            submitLabel: .done,
                            isSecure: true
                        )
                        .focused($focusedField, equals: .password)
                        
                    }
                    
                    Spacer().frame(height: 32)
                    
                    UrSwitchToggle(isOn: $viewModel.termsAgreed) {
                        Text("I agree to URnetwork's ")
                            .foregroundColor(themeManager.currentTheme.textMutedColor)
                            .font(themeManager.currentTheme.secondaryBodyFont)
                        + Text("[Terms and Services](https://ur.io/terms)")
                            .foregroundColor(themeManager.currentTheme.textColor)
                            .font(themeManager.currentTheme.secondaryBodyFont)
                        + Text(" and ")
                            .foregroundColor(themeManager.currentTheme.textMutedColor)
                            .font(themeManager.currentTheme.secondaryBodyFont)
                        + Text("[Privacy Policy](https://ur.io/privacy)")
                            .foregroundColor(themeManager.currentTheme.textColor)
                            .font(themeManager.currentTheme.secondaryBodyFont)
                    }
                    
                    Spacer().frame(height: 48)
                    
                    UrButton(
                        text: "Continue",
                        action: {
                            
                            Task {
                                let result = await viewModel.createNetwork(
                                    userAuth: userAuth,
                                    authJwt: authLoginArgs.authJwt
                                )
                                await handleResult(result)
                            }
                            
                        },
                        enabled: viewModel.formIsValid && !viewModel.isCreatingNetwork
                    )
                    
                }
                .padding()
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: 400)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func handleResult(_ result: LoginNetworkResult) async {
        switch result {
            
        case .successWithJwt(let jwt):
            await handleSuccessWithJwt(jwt)
            break
        case .successWithVerificationRequired:
            if let userAuth = userAuth {
                navigate(.verify(userAuth))
            } else {
                print("CreateNetworkView: successWithVerificationRequired: userAuth is nil")
            }
            break
        case .failure(let error):
            print("CreateNetworkView: handleResult: \(error.localizedDescription)")
            break
            
        }
    }
    
    private func handleSuccessWithJwt(_ jwt: String) async {
        let result = await deviceManager.authenticateNetworkClient(jwt)
        
        if case .failure(let error) = result {
            print("[CreateNetworkView] handleSuccessWithJwt: \(error.localizedDescription)")
            
            snackbarManager.showSnackbar(message: "There was an error creating your network. Please try again later.")
            
            // TODO: clear viewmodel loading state
        }
        
    }
    
    private func getAuthTypeFromArgs(_ args: SdkAuthLoginArgs) -> AuthType {
        
        if args.authJwtType == "apple" {
            return AuthType.apple
        } else {
            return AuthType.password
        }
        
    }
    
}

#Preview {
    ZStack {
        CreateNetworkView(
            authLoginArgs: SdkAuthLoginArgs(),
            navigate: {_ in },
            api: SdkBringYourApi()
        )
    }
    .environmentObject(ThemeManager.shared)
    .background(ThemeManager.shared.currentTheme.backgroundColor)
}
