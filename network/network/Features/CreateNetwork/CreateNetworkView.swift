//
//  CreateNetworkView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import SwiftUI

struct CreateNetworkView: View {
    
    var userAuth: String?
    var authJwt: String?
    var navigate: (LoginInitialNavigationPath) -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject private var viewModel = ViewModel()
    
    @FocusState private var focusedField: Field?

    enum Field {
        case networkName, password
    }
    
    var body: some View {

        GeometryReader { geometry in
            
            ScrollView(.vertical) {
                VStack {
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
                        onClick: {
                            
                            Task {
                                let result = await viewModel.createNetwork(userAuth: userAuth, authJwt: authJwt)
                                handleResult(result)
                            }
                            
                        },
                        enabled: viewModel.formIsValid && !viewModel.isCreatingNetwork
                    )
                    
                }
                .padding()
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func handleResult(_ result: CreateNetworkResult) {
        switch result {
            
            case .successWithJwt(let jwt):
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
}

#Preview {
    CreateNetworkView(
        userAuth: "hello@ur.io",
        navigate: {_ in }
    )
    .environmentObject(ThemeManager.shared)
}
