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
    
    var api: SdkApi
    var cancel: (() -> Void)? = nil
    var handleSuccess: (_ jwt: String) async -> Void
    
    var body: some View {
        NavigationStack(
            path: $viewModel.navigationPath
        ) {
            LoginInitialView(
                api: api,
                navigate: viewModel.navigate,
                cancel: cancel,
                handleSuccess: handleSuccess
            )
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationDestination(for: LoginInitialNavigationPath.self) { path in
                switch path {
                    case .password(let userAuth):
                        LoginPasswordView(
                            userAuth: userAuth,
                            navigate: viewModel.navigate,
                            handleSuccess: handleSuccess,
                            api: api
                        )
                            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
                    case .createNetwork(let authLoginArgs):
                        CreateNetworkView(
                            authLoginArgs: authLoginArgs,
                            navigate: viewModel.navigate,
                            handleSuccess: handleSuccess,
                            api: api
                        )
                            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
                    case .verify(let userAuth):
                        CreateNetworkVerifyView(
                            userAuth: userAuth,
                            api: api,
                            navigate: viewModel.navigate,
                            handleSuccess: handleSuccess
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
        api: SdkApi(),
        handleSuccess: {_ in }
    )
}
