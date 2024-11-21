//
//  LoginNavigationView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import SwiftUI

struct LoginNavigationView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack(
            path: $viewModel.navigationPath
//            root: {
//                LoginInitialView(
//                    navigate: viewModel.navigate
//                )
//            }
        ) {
            LoginInitialView(
                navigate: viewModel.navigate
            )
            .navigationDestination(for: LoginInitialNavigationPath.self) { path in
                switch path {
                    case .password(let userAuth):
                        LoginPasswordView(userAuth: userAuth)
                    case .createNetwork(let userAuth):
                        CreateNetworkView(userAuth: userAuth)
                }
            }
        }
        .background(ThemeManager.shared.currentTheme.systemBackground.ignoresSafeArea())
    }
}

#Preview {
    LoginNavigationView()
}
