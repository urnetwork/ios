//
//  CreateNetworkView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import SwiftUI

struct CreateNetworkView: View {
    
    var userAuth: String
    
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
                    
                    UrTextField(
                        text: $viewModel.userAuth,
                        label: "Email or phone number",
                        placeholder: "Enter your phone number or email",
                        isEnabled: false,
                        keyboardType: .emailAddress,
                        submitLabel: .next
                    )
                    
                    Spacer().frame(height: 24)
                    
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
                        focusedField = .password
                    }
                    
                    Spacer().frame(height: 24)
                    
                    UrTextField(
                        text: $viewModel.password,
                        label: "Password",
                        placeholder: "************",
                        submitLabel: .done,
                        isSecure: true
                    )
                    .focused($focusedField, equals: .password)
                    
                    // todo - custom switch
                    
                    Spacer().frame(height: 48)
                    
                    UrButton(text: "Continue", onClick: {})
                    
                }
                .padding()
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            viewModel.setUserAuth(userAuth)
        }
        
    }
}

#Preview {
    CreateNetworkView(
        userAuth: "hello@ur.io"
    )
    .environmentObject(ThemeManager.shared)
    .applySystemBackground()
}
