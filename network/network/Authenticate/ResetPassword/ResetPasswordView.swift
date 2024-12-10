//
//  ResetPasswordView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/07.
//

import SwiftUI
import URnetworkSdk

struct ResetPasswordView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var snackbarManager: UrSnackbarManager
    
    @StateObject private var viewModel: ViewModel
    
    var userAuth: String
    var popNavigationStack: () -> Void
    
    init(
        userAuth: String,
        popNavigationStack: @escaping () -> Void,
        api: SdkBringYourApi
    ) {
        _viewModel = StateObject(wrappedValue: ViewModel(api: api))
        self.userAuth = userAuth
        self.popNavigationStack = popNavigationStack
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack {
                    Text("Forgot your password?")
                        .foregroundColor(.urWhite)
                        .font(themeManager.currentTheme.titleFont)
                    
                    Spacer().frame(height: 64)
                    
                    UrTextField(
                        text: .constant(userAuth),
                        label: "Email or phone number",
                        placeholder: "Enter your phone number or email",
                        isEnabled: false
                    )
                    
                    Spacer().frame(height: 8)
                    
                    HStack {
                        Text("You may need to your check spam folder or unblock no-reply@ur.io")
                            .font(themeManager.currentTheme.secondaryBodyFont)
                            .foregroundColor(themeManager.currentTheme.textMutedColor)
                        Spacer()
                    }
                    
                    Spacer().frame(height: 24)
                    
                    UrButton(
                        text: "Send reset link",
                        action: {
                            Task {
                                await handleResendLink()
                            }
                        },
                        enabled: !viewModel.sendInProgress
                    )
                }
                .padding()
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: 400)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func handleResendLink() async {
        
        let result = await viewModel.sendResetLink(userAuth)
        
        switch result {
            
        case .success:
            
            snackbarManager.showSnackbar(message: "Password reset link sent to \(userAuth).")
            
            self.popNavigationStack()
            break
            
        case .failure(let error):
            print("error sending reset link: \(error.localizedDescription)")
            
            snackbarManager.showSnackbar(message: "There was an error sending a password reset link to \(userAuth).")
            
            break
        }
        
    }
}

#Preview {
    ZStack {
        ResetPasswordView(
            userAuth: "hello@ur.io",
            popNavigationStack: {},
            api: SdkBringYourApi()
        )
    }
    .environmentObject(ThemeManager.shared)
    .background(ThemeManager.shared.currentTheme.backgroundColor)
}
