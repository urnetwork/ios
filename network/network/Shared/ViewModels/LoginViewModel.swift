////
////  LoginViewModel.swift
////  URnetwork
////
////  Created by Stuart Kuentzel on 2025/01/19.
////
//
//import Foundation
//import URnetworkSdk
//
//@MainActor
//class LoginViewModel: ObservableObject {
//    
//    @Published private(set) var isInProgress: Bool = false
//    
//    private var api: SdkApi
//    
//    init(api: SdkApi) {
//        self.api = api
//    }
//    
//    
//    func authLogin(args: SdkAuthLoginArgs) async -> AuthLoginResult {
//        
//        if isInProgress {
//            return .failure(AuthLoginError.isInProgress)
//        }
//        
//        self.isInProgress = true
//        
//        do {
//            let result: AuthLoginResult = try await withCheckedThrowingContinuation { [weak self] continuation in
//                
//                guard let self = self else { return }
//                
//                let callback = AuthLoginCallback { [weak self] result, error in
//                    
//                    guard let self = self else { return }
//                     
//                    if let error {
//
//                        continuation.resume(throwing: error)
//                        
//                        return
//                    }
//                    
//                    guard let result else {
//                        
//                        continuation.resume(throwing: AuthLoginError.invalidResult)
//                        
//                        return
//                    }
//                    
//                    if let resultError = result.error {
//                        
//                        continuation.resume(throwing: AuthLoginError.invalidResult)
//                        
//                        return
//                    }
//                    
//                    // JWT exists, proceed to authenticate network
//                    if let jwt = result.network?.byJwt {
//                        continuation.resume(returning: .login(jwt))
//                        return
//                    }
//                    
//                    // user auth requires password
//                    if let authAllowed = result.authAllowed {
//                        
//                        if authAllowed.contains("password") {
//                            
//                            /**
//                             * Login
//                             */
//                            continuation.resume(returning: .promptPassword(result))
//                            
//                        } else {
//                            
//                            continuation.resume(throwing: AuthLoginError.invalidArguments)
//                            
//                        }
//                        
//                        return
//                        
//                    }
//                                   
//                    /**
//                     * Create new network
//                     */
//                    continuation.resume(returning: .create(args))
//                    
//                }
//                
//                api.authLogin(args, callback: callback)
//                
//            }
//            
//            DispatchQueue.main.async {
//                self.isInProgress = false
//            }
//            
//            return result
//            
//        } catch {
//            DispatchQueue.main.async {
//                self.isInProgress = false
//            }
//            return .failure(error)
//        }
//        
//    }
//    
//}
//
//
//private class AuthLoginCallback: SdkCallback<SdkAuthLoginResult, SdkAuthLoginCallbackProtocol>, SdkAuthLoginCallbackProtocol {
//    func result(_ result: SdkAuthLoginResult?, err: Error?) {
//        handleResult(result, err: err)
//    }
//}
//
//private class UpgradeGuestExistingCallback: SdkCallback<SdkUpgradeGuestExistingResult, SdkUpgradeGuestExistingCallbackProtocol>, SdkUpgradeGuestExistingCallbackProtocol {
//    func result(_ result: SdkUpgradeGuestExistingResult?, err: Error?) {
//        handleResult(result, err: err)
//    }
//}
