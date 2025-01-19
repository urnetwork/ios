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
import GoogleSignIn

extension LoginInitialView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        private var api: SdkApi?
        
        @Published var userAuth: String = "" {
            didSet {
                isValidUserAuth = ValidationUtils.isValidUserAuth(userAuth)
            }
        }

        @Published private(set) var isValidUserAuth: Bool = false
        
        @Published private(set) var isCheckingUserAuth: Bool = false
        
        // TODO: deprecate this
        @Published private(set) var loginErrorMessage: String?
        
        /**
         * Guest mode
         */
        @Published private(set) var isCreatingGuestNetwork: Bool = false
        @Published var presentGuestNetworkSheet: Bool = false
        @Published var termsAgreed: Bool = false
        
        let termsLink = "https://ur.io/terms"
        
        let domain = "LoginInitialViewModel"
        
        init(api: SdkApi?) {
            self.api = api
        }
        
        func authLogin(args: SdkAuthLoginArgs) async -> AuthLoginResult {
            
            do {
                let result: AuthLoginResult = try await withCheckedThrowingContinuation { [weak self] continuation in
                    
                    guard let self = self else { return }
                    
                    let callback = AuthLoginCallback { [weak self] result, error in
                        
                        guard let self = self else { return }
                         
                        if let error {

                            continuation.resume(throwing: error)
                            
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
                        
                        // JWT exists, proceed to authenticate network
                        if let jwt = result.network?.byJwt {
                            continuation.resume(returning: .login(jwt))
                            return
                        }
                        
                        // user auth requires password
                        if let authAllowed = result.authAllowed {
                            
                            if authAllowed.contains("password") {
                                
                                /**
                                 * Login
                                 */
                                continuation.resume(returning: .promptPassword(result))
                                
                            } else {
                                
                                continuation.resume(throwing: NSError(domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: "authAllowed missing password: \(authAllowed)"]))
                                
                            }
                            
                            return
                            
                        }
                                       
                        /**
                         * Create new network
                         */
                        continuation.resume(returning: .create(args))
                        
                    }
                    
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
        
        func linkGuestToExistingSocialLogin(args: SdkAuthLoginArgs) async -> AuthLoginResult {
            
            do {
                
                let result: AuthLoginResult = try await withCheckedThrowingContinuation { [weak self] continuation in
                    
                    guard let self = self else { return }
                    
                    let callback = UpgradeGuestExistingCallback { [weak self] result, error in
                        
                        guard let self = self else { return }
                        
                        guard let result else {
                            
                            continuation.resume(throwing: NSError(domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: "No result found"]))
                            
                            return
                        }
                        
                        if let resultError = result.error {
                            
                            continuation.resume(throwing: NSError(domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: "result.error exists \(resultError.message)"]))
                            
                            return
                        }
                        
                        
                        // JWT exists, proceed to authenticate network
                        if let jwt = result.network?.byJwt {
                            continuation.resume(returning: .login(jwt))
                            return
                        }
                        
                        
                    }
                    
                    let upgradeArgs = SdkUpgradeGuestExistingArgs()
                    upgradeArgs.authJwt = args.authJwt
                    upgradeArgs.authJwtType = args.authJwtType
                    
                    api?.upgradeGuestExisting(upgradeArgs, callback: callback)
                    
                }
                
                return result
                
            } catch(let error) {
                return .failure(error)
            }
            
        }
        
    }
}

// MARK: Handle UserAuth Login
extension LoginInitialView.ViewModel {
    
    // func getStarted() async -> AuthLoginResult {
    func getStarted() -> Result<SdkAuthLoginArgs, Error> {
        
        if isCheckingUserAuth {
            return .failure(NSError(domain: domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Auth login already in progress"]))
        }
        
        if !isValidUserAuth {
            return .failure(NSError(domain: domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Form invalid"]))
        }
        
        DispatchQueue.main.async {
            self.isCheckingUserAuth = true
        }
        
        let args = SdkAuthLoginArgs()
        args.userAuth = userAuth
        
        return .success(args)
        
        // return await authLogin(args: args)
    }
    
}

// MARK: Handle Apple Login
extension LoginInitialView.ViewModel {
    
    // func handleAppleLoginResult(_ result: Result<ASAuthorization, any Error>) async -> AuthLoginResult {
    func createAppleAuthLoginArgs(_ result: Result<ASAuthorization, any Error>) -> Result<SdkAuthLoginArgs, Error> {
        
        switch result {
            
            case .success(let authResults):
                
                // get the id token to use as authJWT
                switch authResults.credential {
                    case let credential as ASAuthorizationAppleIDCredential:
                    
                    guard let idToken = credential.identityToken else {
                        return .failure(LoginError.appleLoginFailed)
                    }
                    
                    guard let idTokenString = String(data: idToken, encoding: .utf8) else {
                        return .failure(LoginError.appleLoginFailed)
                    }
                        
                    let args = SdkAuthLoginArgs()
                    args.authJwt = idTokenString
                    args.authJwtType = "apple"
                    
                    return .success(args)
                    
                    // return await authLogin(args: args)

                default:
                        
                    return .failure(LoginError.appleLoginFailed)
                }
                
            
            case .failure(let error):
                print("Authorisation failed: \(error.localizedDescription)")
                return .failure(error)
            
        }
        
    }
    
}

// MARK: handle Google login result
extension LoginInitialView.ViewModel {
    
    // func handleGoogleLoginResult(_ result: GIDSignInResult?) async -> AuthLoginResult {
    func createGoogleAuthLoginArgs(_ result: GIDSignInResult?) -> Result<SdkAuthLoginArgs, Error> {
        
        guard let result = result else {
            return .failure(LoginError.googleNoResult)
        }
        
        guard let idTokenString = result.user.idToken?.tokenString else {
            return .failure(LoginError.googleNoIdToken)
        }
        
        let args = SdkAuthLoginArgs()
        args.authJwt = idTokenString
        args.authJwtType = "google"
        
        return .success(args)
        
        // return await authLogin(args: args)
        
    }
    
}

// MARK: create guest network
extension LoginInitialView.ViewModel {
    
    func createGuestNetwork() async -> LoginNetworkResult {
        
        print("create guest network")
        
        if self.isCreatingGuestNetwork {
            return .failure(LoginError.inProgress)
        }
        
        self.isCreatingGuestNetwork = true
        
        do {
            
            let result: LoginNetworkResult = try await withCheckedThrowingContinuation { [weak self] continuation in
                
                guard let self = self else { return }
                
                let callback = NetworkCreateCallback { result, err in
                    
                    if let err = err {
                        continuation.resume(throwing: err)
                        return
                    }
                    
                    if let result = result {
                        
                        if let resultError = result.error {

                            continuation.resume(throwing: NSError(domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: resultError.message]))
                            
                            return
                            
                        }
                        
                        if let network = result.network {
                            print("result.network exists! good to go")
                            
                            continuation.resume(returning: .successWithJwt(network.byJwt))
                            return
                            
                        } else {
                            continuation.resume(throwing: NSError(domain: self.domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "No network object found in result"]))
                            return
                        }
                        
                    }
                    
                }
                
                let args = SdkNetworkCreateArgs()
                args.terms = true
                args.guestMode = true
                
                api?.networkCreate(args, callback: callback)
                
            }
            
            DispatchQueue.main.async {
                self.isCreatingGuestNetwork = false
            }
            
            return result
            
        } catch(let error) {
            DispatchQueue.main.async {
                self.isCreatingGuestNetwork = false
            }
            return .failure(error)
        }
        
    }
    
}

private class AuthLoginCallback: SdkCallback<SdkAuthLoginResult, SdkAuthLoginCallbackProtocol>, SdkAuthLoginCallbackProtocol {
    func result(_ result: SdkAuthLoginResult?, err: Error?) {
        handleResult(result, err: err)
    }
}

private class UpgradeGuestExistingCallback: SdkCallback<SdkUpgradeGuestExistingResult, SdkUpgradeGuestExistingCallbackProtocol>, SdkUpgradeGuestExistingCallbackProtocol {
    func result(_ result: SdkUpgradeGuestExistingResult?, err: Error?) {
        handleResult(result, err: err)
    }
}

enum LoginError: Error {
    case appleLoginFailed
    case googleLoginFailed
    case googleNoResult
    case googleNoIdToken
    case inProgress
}

