//
//  LoginInitialView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/20.
//

import SwiftUI
import URnetworkSdk

struct LoginInitialView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    // @EnvironmentObject var networkSpaceStore: NetworkSpaceStore
    // @StateObject private var viewModel = ViewModel()
    @StateObject private var viewModel: ViewModel
    
    var api: SdkBringYourApi?
    var navigate: (LoginInitialNavigationPath) -> Void
    
    init(api: SdkBringYourApi?, navigate: @escaping (LoginInitialNavigationPath) -> Void) {
        _viewModel = StateObject(wrappedValue: ViewModel(api: api))
        self.navigate = navigate
    }
    
    // todo - login with apple
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ScrollView(.vertical) {
                
                VStack {
                    
                    LoginCarousel()
                    
                    Spacer().frame(height: 32)
                    
                    UrTextField(
                        text: $viewModel.userAuth,
                        label: "Email or phone",
                        placeholder: "Enter your phone number or email",
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
                    
                    Text("or", comment: "Referring to the two options 'Get started' *or* 'Login with Apple'")
                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                    
                    Spacer()
                        .frame(height: 24)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
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
}

#Preview {
    LoginInitialView(
        api: nil,
        navigate: {_ in }
    )
        .environmentObject(ThemeManager.shared)
}
