//
//  LoginInitialViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/20.
//

import Foundation
import URnetworkSdk
import SwiftUI

private class AuthLoginCallback: SdkCallback<SdkAuthLoginResult, SdkAuthLoginCallbackProtocol>, SdkAuthLoginCallbackProtocol {
    func result(_ result: SdkAuthLoginResult?, err: Error?) {
        handleResult(result, err: err)
    }
}

extension LoginInitialView {
    
    class ViewModel: ObservableObject {
        
        // private let api = NetworkSpaceManager.shared.networkSpace?.getApi()
//        @EnvironmentObject var networkSpaceStore: NetworkSpaceStore
//        
//        private var api: SdkBringYourApi? {
//            return networkSpaceStore.api
//        }
        
        private var api: SdkBringYourApi?
        
        @Published var userAuth: String = "" {
            didSet {
                isValidUserAuth = ValidationUtils.isValidUserAuth(userAuth)
            }
        }

        @Published private(set) var isValidUserAuth: Bool = false
        
        @Published private(set) var isCheckingUserAuth: Bool = false
        
        @Published private(set) var loginErrorMessage: String?
        
        init(api: SdkBringYourApi?) {
            self.api = api
        }
        
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
                
                DispatchQueue.main.async {
                 
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
                        
                        self.isCheckingUserAuth = false
                        
                        return
                        
                    }
                    
                    // on new network
                    navigateToCreateNetwork()
                    
                    
                    self.isCheckingUserAuth = false
                    
                }
                
            }
            
            api?.authLogin(args, callback: callback)
            
        }
    }
}
