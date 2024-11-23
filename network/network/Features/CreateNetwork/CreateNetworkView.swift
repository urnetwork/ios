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
                    Text("Join URnetwork")
                        .foregroundColor(.urWhite)
                        .font(themeManager.currentTheme.titleFont)
                    
                    Spacer().frame(height: 48)
                    
                    UrTextField(
                        text: $viewModel.userAuth,
                        placeholder: "Enter your phone number or email",
                        isEnabled: false,
                        label: "Email of phone number",
                        keyboardType: .emailAddress,
                        submitLabel: .next
                    )
                    
                    Spacer().frame(height: 24)
                    
                    UrTextField(
                        text: $viewModel.networkName,
                        placeholder: "Enter a name for your network",
                        label: "Network name",
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
                        placeholder: "************",
                        label: "Password",
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
