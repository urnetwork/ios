//
//  LoginNavigationView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import SwiftUI
import URnetworkSdk

struct LoginNavigationView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var api: SdkBringYourApi
    
    var authenticateNetworkClient: (String) async -> Result<Void, Error>
    
//    init() {
//        _viewModel = StateObject(wrappedValue: ViewModel(api: api))
//    }
    
    var body: some View {
        NavigationStack(
            path: $viewModel.navigationPath
        ) {
            LoginInitialView(
                api: api,
                navigate: viewModel.navigate,
                authenticateNetworkClient: authenticateNetworkClient
            )
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationDestination(for: LoginInitialNavigationPath.self) { path in
                switch path {
                    case .password(let userAuth):
                        LoginPasswordView(
                            userAuth: userAuth,
                            navigate: viewModel.navigate,
                            authenticateNetworkClient: authenticateNetworkClient,
                            api: api
                        )
                            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
                    case .createNetwork(let authLoginArgs):
                        CreateNetworkView(
                            authLoginArgs: authLoginArgs,
                            navigate: viewModel.navigate,
                            authenticateNetworkClient: authenticateNetworkClient,
                            api: api
                        )
                            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
                    case .verify(let userAuth):
                        CreateNetworkVerifyView(
                            userAuth: userAuth,
                            api: api,
                            navigate: viewModel.navigate,
                            authenticateNetworkClient: authenticateNetworkClient
                        )
                            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
                case .resetPassword(let userAuth):
                    ResetPasswordView(
                        userAuth: userAuth,
                        popNavigationStack: viewModel.back,
                        api: api
                    )
                }
            }
        }
    }
}

#Preview {
    LoginNavigationView(
        api: SdkBringYourApi(),
        authenticateNetworkClient: { _ in
            return .success(())
        }
    )
}
