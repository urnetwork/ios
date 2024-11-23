//
//  LoginInitialView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/20.
//

import SwiftUI

struct LoginInitialView: View {
    
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    
    var navigate: (LoginInitialNavigationPath) -> Void
    
    private func getStarted() {
        viewModel.getStarted(
            navigateToLogin: {
                navigate(.password(viewModel.userAuth))
            },
            navigateToCreateNetwork: {
                navigate(.createNetwork(viewModel.userAuth))
            }
        )
    }
    
    // todo - login with apple
    
    var body: some View {
        VStack {

            UrTextField(
                text: $viewModel.userAuth,
                placeholder: "Enter your phone number or email",
                label: "Email or phone",
                onTextChange: { newValue in
                    // Filter whitespace
                    if newValue.contains(" ") {
                        viewModel.userAuth = newValue.filter { !$0.isWhitespace }
                    }
                },
                keyboardType: .emailAddress,
                submitLabel: .continue,
                onSubmit: getStarted
            )
            
            Spacer()
                .frame(height: 32)
            
            UrButton(
                text: "Get started",
                onClick: getStarted,
                enabled: viewModel.isValidUserAuth && !viewModel.isCheckingUserAuth
            )
            
            Spacer()
                .frame(height: 24)
            
            Text("or")
                .foregroundColor(themeManager.currentTheme.textMutedColor)
            
            Spacer()
                .frame(height: 24)
            
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .applySystemBackground()
    }
}

#Preview {
    LoginInitialView(
        navigate: {_ in }
    )
        .environmentObject(ThemeManager.shared)
}
