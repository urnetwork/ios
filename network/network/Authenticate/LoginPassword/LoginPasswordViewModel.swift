//
//  LoginPasswordViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import Foundation
import URnetworkSdk
import SwiftUI

private class AuthLoginPasswordCallback: SdkCallback<SdkAuthLoginWithPasswordResult, SdkAuthLoginWithPasswordCallbackProtocol>, SdkAuthLoginWithPasswordCallbackProtocol {
    func result(_ result: SdkAuthLoginWithPasswordResult?, err: Error?) {
        handleResult(result, err: err)
    }
}

extension LoginPasswordView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        private var api: SdkApi?
        
        @Published private(set) var isValid: Bool = false
        
        @Published private(set) var isLoggingIn: Bool = false
        
        @Published var password: String = "" {
            didSet {
                isValid = !password.isEmpty
            }
        }
        
        private let domain = "LoginPassword.ViewModel"
        
        init(api: SdkApi?) {
            self.api = api
        }
        
        func setIsLoggingIn(_ isLoggingIn: Bool) {
            self.isLoggingIn = isLoggingIn
        }
        
        func loginWithPassword(userAuth: String) async -> LoginNetworkResult {
            
            if !isValid {
                return .failure(NSError(domain: domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Form invalid"]))
            }
            
            if isLoggingIn {
                return .failure(NSError(domain: domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Login already in progress"]))
            }
            
            self.setIsLoggingIn(true)
            
            do {
                let result: LoginNetworkResult = try await withCheckedThrowingContinuation { [weak self] continuation in
                    
                    guard let self = self else { return }
                    
                    let callback = AuthLoginPasswordCallback { result, err in
                        
                        if let err = err {
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        if let result = result {
                            
                            if let resultError = result.error {

                                continuation.resume(throwing: NSError(domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: resultError.message]))
                                
                                return
                                
                            }
                            
                            
                            if (result.verificationRequired != nil) {
                                continuation.resume(returning: .successWithVerificationRequired)
                                return
                            }
                            
                            if let network = result.network {
                                
                                continuation.resume(returning: .successWithJwt(network.byJwt))
                                return
                                
                            } else {
                                continuation.resume(throwing: NSError(domain: self.domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "No network object found in result"]))
                                return
                            }
                            
                        } else {
                            continuation.resume(throwing: NSError(domain: self.domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "No error or result found"])
                            )
                        }
                        
                    }
                    
                    let args = SdkAuthLoginWithPasswordArgs()
                    args.userAuth = userAuth
                    args.password = self.password
                    args.verifyOtpNumeric = true
                    
                    if let api = api {
                        
                        api.authLogin(withPassword: args, callback: callback)
                        
                    } else {
                        continuation.resume(throwing: NSError(domain: domain, code: -1, userInfo: [NSLocalizedDescriptionKey: "API not instantiated"]))
                    }
                    
                }
                
//                DispatchQueue.main.async {
//                    self.isLoggingIn = false
//                }
                
                return result
            } catch {
                return .failure(error)
            }
            
        }
    }
}
