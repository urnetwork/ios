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
    
    var navigate: () -> Void
    
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
                }
            )
            
            Spacer()
                .frame(height: 32)
            
            UrButton(
                text: "Get started",
                onClick: {
                    // viewModel.navigate
                    navigate()
                }
            )
            
            Spacer()
                .frame(height: 24)
            
            Text("or")
                .foregroundColor(themeManager.currentTheme.textMutedColor)
            
            Spacer()
                .frame(height: 24)
            
            
            
        }
//        .navigationDestination(for: LoginInitialNavigationPath.self) { path in
//            switch path {
//                case .password(let userAuth):
//                    LoginPasswordView(userAuth: userAuth)
//                case .createNetwork(let userAuth):
//                    CreateNetworkView(userAuth: userAuth)
//            }
//        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .applySystemBackground()
    }
}

#Preview {
    LoginInitialView(
        navigate: {}
    )
        .environmentObject(ThemeManager.shared)
}
