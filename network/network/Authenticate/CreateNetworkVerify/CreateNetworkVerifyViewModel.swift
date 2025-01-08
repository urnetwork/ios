//
//  CreateNetworkVerifyViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/27.
//

import Foundation
import URnetworkSdk
import SwiftUI
import Combine

// for verifying the OTP
private class AuthVerifyCallback: SdkCallback<SdkAuthVerifyResult, SdkAuthVerifyCallbackProtocol>, SdkAuthVerifyCallbackProtocol {
    func result(_ result: SdkAuthVerifyResult?, err: Error?) {
        handleResult(result, err: err)
    }
}


// For resending the OTP
private class AuthVerifySendCallback: SdkCallback<SdkAuthVerifySendResult, SdkAuthVerifySendCallbackProtocol>, SdkAuthVerifySendCallbackProtocol {
    func result(_ result: SdkAuthVerifySendResult?, err: Error?) {
        handleResult(result, err: err)
    }
}


extension CreateNetworkVerifyView {
    
    class ViewModel: ObservableObject {
        
        private var api: SdkApi?
        
        private var userAuth: String
        
        let codeCount = 6
        
        @Published var otp: String = ""
        
        @Published private(set) var isSubmitting: Bool = false
        
        @Published private(set) var isSendingOtp: Bool = false
        
        @Published private(set) var resetBtnEnabled: Bool = true
        
        private var cancellables = Set<AnyCancellable>()
        
        private let domain = "CraeteNetworkVerifyViewModel"
        
        init(api: SdkApi?, userAuth: String) {
            self.api = api
            self.userAuth = userAuth
        }
        
        func resendOtp() async -> Result<Void, Error> {
            
            if isSendingOtp {
                return .failure(NSError(domain: domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "OTP is already being sent"]))
            }
            
            DispatchQueue.main.async {
                self.isSendingOtp = true
                self.resetBtnEnabled = false
            }
            
            do {
                let result: Void = try await withCheckedThrowingContinuation { continuation in
                    
                    let callback = AuthVerifySendCallback { result, err in
                        
                        if let err = err {
                            print(err.localizedDescription)
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        continuation.resume(returning: ())
                        
                    }
                    
                    if let api = api {
                        
                        let args = SdkAuthVerifySendArgs()
                        args.userAuth = self.userAuth
                        args.useNumeric = true
                        
                        api.authVerifySend(args, callback: callback)
                    }
                    
                }
                
                
                DispatchQueue.main.async {
                    self.isSendingOtp = false
                    self.startResendButtonTimer()
                }
                
                return .success(result)
                
            } catch {
                isSendingOtp = false
                return .failure(error)
            }
                
        }
        
        
        private func startResendButtonTimer() {
            let delay = 15
            Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .scan(delay) { counter, _ in counter - 1 }
                .prefix(while: { $0 > 0 })
                .sink { _ in
                    self.resetBtnEnabled = true
                }
                .store(in: &cancellables)
        }
        
        deinit {
            cancellables.removeAll()
        }
        
        func submit() async -> Result<String, Error> {
      
            if isSubmitting {
                return .failure(NSError(domain: domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "OTP is already being sent"]))
            }
            
            DispatchQueue.main.async {
                self.isSubmitting = true
            }
            
            do {
                
                let result: String = try await withCheckedThrowingContinuation { continuation in
                    
                    let callback = AuthVerifyCallback { [weak self] result, err in
                        
                        guard let self = self else { return }
                        
                        if let err = err {
                            print(err.localizedDescription)
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        guard let result = result else {
                            continuation.resume(throwing: NSError(domain: domain, code: -1, userInfo: [NSLocalizedDescriptionKey: "verify result is nil"]))
                            return
                        }
                        
                        if let resultError = result.error {
                            continuation.resume(throwing: NSError(domain: domain, code: -1, userInfo: [NSLocalizedDescriptionKey: resultError.message]))
                            
                            return
                        }
                        
                        if let network = result.network {
                            
                            if network.byJwt.isEmpty == false {
                                continuation.resume(returning: network.byJwt)
                            } else {
                                continuation.resume(throwing: NSError(domain: domain, code: -1, userInfo: [NSLocalizedDescriptionKey: "byJWT is empty"]))
                            }
                            
                        } else {
                            continuation.resume(throwing: NSError(domain: domain, code: -1, userInfo: [NSLocalizedDescriptionKey: "network is nil"]))
                        }
                        
                    }
                    
                    if let api = api {
                        
                        let args = SdkAuthVerifyArgs()
                        args.verifyCode = otp
                        args.userAuth = userAuth
                        
                        api.authVerify(args, callback: callback)
                    }
                    
                }
                
                DispatchQueue.main.async {
                    self.isSubmitting = false
                }
                
                return .success(result)
                
            } catch {
                
                
                DispatchQueue.main.async {
                    self.isSubmitting = false
                }
                
                return .failure(error)
            }
        }
    }
}
