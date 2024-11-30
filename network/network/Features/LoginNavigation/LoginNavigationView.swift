//
//  LoginNavigationView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import SwiftUI

struct LoginNavigationView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack(
            path: $viewModel.navigationPath
        ) {
            LoginInitialView(
                navigate: viewModel.navigate
            )
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationDestination(for: LoginInitialNavigationPath.self) { path in
                switch path {
                    case .password(let userAuth):
                        LoginPasswordView(
                            userAuth: userAuth,
                            navigate: viewModel.navigate
                        )
                            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
                    case .createNetwork(let userAuth):
                        CreateNetworkView(
                            userAuth: userAuth,
                            navigate: viewModel.navigate
                        )
                            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
                    case .verify(let userAuth):
                        CreateNetworkVerifyView(userAuth: userAuth)
                            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
                }
            }
        }
    }
}

#Preview {
    LoginNavigationView()
}
