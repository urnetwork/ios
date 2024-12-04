//
//  LoginInitialViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/20.
//

import Foundation
import URnetworkSdk
import SwiftUI
import AuthenticationServices

private class AuthLoginCallback: SdkCallback<SdkAuthLoginResult, SdkAuthLoginCallbackProtocol>, SdkAuthLoginCallbackProtocol {
    func result(_ result: SdkAuthLoginResult?, err: Error?) {
        handleResult(result, err: err)
    }
}
enum LoginError: Error {
    case appleLoginFailed
}

extension LoginInitialView {
    
    class ViewModel: ObservableObject {
        
        private var api: SdkBringYourApi?
        
        @Published var userAuth: String = "" {
            didSet {
                isValidUserAuth = ValidationUtils.isValidUserAuth(userAuth)
            }
        }

        @Published private(set) var isValidUserAuth: Bool = false
        
        @Published private(set) var isCheckingUserAuth: Bool = false
        
        // TODO: deprecate this
        @Published private(set) var loginErrorMessage: String?
        
        let domain = "LoginInitialViewModel"
        
        init(api: SdkBringYourApi?) {
            self.api = api
        }
        
        private func authLogin(args: SdkAuthLoginArgs) async -> AuthLoginResult {
            
            print("auth login hit")
            
            do {
                let result: AuthLoginResult = try await withCheckedThrowingContinuation { [weak self] continuation in
                    
                    guard let self = self else { return }
                    
                    let callback = AuthLoginCallback { [weak self] result, error in
                        
                        print("inside auth login callback")
                        
                        guard let self = self else { return }
                        
                        
                         
                        if let error {

                            continuation.resume(throwing: NSError(domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: "error exists \(error)"]))
                            
                            return
                        }
                        
                        guard let result else {
                            
                            continuation.resume(throwing: NSError(domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: "No result found"]))
                            
                            return
                        }
                        
                        if let resultError = result.error {
                            
                            continuation.resume(throwing: NSError(domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: "result.error exists \(resultError.message)"]))
                            
                            return
                        }
                        
                        if let authAllowed = result.authAllowed {
                            
                            if authAllowed.contains("password") {
                                
                                /**
                                 * Login
                                 */
                                print("should login")
                                
                                continuation.resume(returning: .login(result))
                                
                            } else {
                                
                                continuation.resume(throwing: NSError(domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: "authAllowed missing password: \(authAllowed)"]))
                                
                            }
                            
                            return
                            
                        }
                        
                        print("should create new network")
                                       
                        /**
                         * Create new network
                         */
                        continuation.resume(returning: .create(args))
                        
                    }
                    
                    print("auth jwt is: \(args.authJwt)")
                    print("auth jwt type is: \(args.authJwtType)")
                    
                    api?.authLogin(args, callback: callback)
                    
                }
                
                DispatchQueue.main.async {
                    self.isCheckingUserAuth = false
                }
                
                return result
                
            } catch {
                return .failure(error)
            }
            
        }
    }
}

// MARK: Handle UserAuth Login
extension LoginInitialView.ViewModel {
    
    func getStarted() async -> AuthLoginResult {
        
        if isCheckingUserAuth {
            return .failure(NSError(domain: domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Auth login already in progress"]))
        }
        
        if !isValidUserAuth {
            return .failure(NSError(domain: domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Form invalid"]))
        }
        
        isCheckingUserAuth = true
        
        let args = SdkAuthLoginArgs()
        args.userAuth = userAuth
        
        return await authLogin(args: args)
    }
    
}

// MARK: Handle Apple Login
extension LoginInitialView.ViewModel {
    
    func handleAppleLoginResult(_ result: Result<ASAuthorization, any Error>) async -> AuthLoginResult {
        
        print("handleAppleLoginResult hit")
        
        switch result {
            
            case .success(let authResults):
                
                // get the id token to use as authJWT
                switch authResults.credential {
                    case let credential as ASAuthorizationAppleIDCredential:
                    
                        guard let idToken = credential.identityToken else {
                            return .failure(LoginError.appleLoginFailed)
                        }
                        
                        let args = SdkAuthLoginArgs()
                    
                        args.authJwt = idToken.base64EncodedString()
                        args.authJwtType = "apple"
                        
                    
                        return await authLogin(args: args)

                    default:
                        return .failure(LoginError.appleLoginFailed)
                }
                
            
            case .failure(let error):
                print("Authorisation failed: \(error.localizedDescription)")
                return .failure(error)
            
        }
        
    }
    
}
