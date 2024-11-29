//
//  LoginInitialViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/20.
//

import Foundation
import URnetworkSdk

private class AuthLoginCallback: SdkCallback<SdkAuthLoginResult, SdkAuthLoginCallbackProtocol>, SdkAuthLoginCallbackProtocol {
    func result(_ result: SdkAuthLoginResult?, err: Error?) {
        handleResult(result, err: err)
    }
}

extension LoginInitialView {
    
    class ViewModel: ObservableObject {
        
        private let api = NetworkSpaceManager.shared.networkSpace?.getApi()
        
        @Published var userAuth: String = "" {
            didSet {
                isValidUserAuth = ValidationUtils.isValidUserAuth(userAuth)
            }
        }

        @Published private(set) var isValidUserAuth: Bool = false
        
        @Published private(set) var isCheckingUserAuth: Bool = false
        
        @Published private(set) var loginErrorMessage: String?
        
        func getStarted(
            navigateToLogin: @escaping () -> Void,
            navigateToCreateNetwork: @escaping () -> Void
        ) {
            
            if !isValidUserAuth || isCheckingUserAuth {
                return
            }
            
            isCheckingUserAuth = true
            
            let args = SdkAuthLoginArgs()
            args.userAuth = userAuth
            
            let callback = AuthLoginCallback { [weak self] result, error in
                
                guard let self = self else { return }
                
                if let error {
                    self.loginErrorMessage = error.localizedDescription
                    self.isCheckingUserAuth = false
                    return
                }
                
                if let resultError = result?.error {
                    self.loginErrorMessage = resultError.message
                    self.isCheckingUserAuth = false
                    return
                }
                
                if let authAllowed = result?.authAllowed {
                    
                    if authAllowed.contains("password") {
                        self.loginErrorMessage = nil
                        
                        // login
                        navigateToLogin()
                    } else {
                        print("authAllowed missing password: \(authAllowed)")
                        
                        // todo - localize this
                        self.loginErrorMessage = "An error occurred. Please try again later."
                    }
                    
                    isCheckingUserAuth = false
                    
                    return
                    
                }
                
                // on new network
                navigateToCreateNetwork()
                isCheckingUserAuth = false
                
            }
            
            api?.authLogin(args, callback: callback)
            
        }
    }
}
