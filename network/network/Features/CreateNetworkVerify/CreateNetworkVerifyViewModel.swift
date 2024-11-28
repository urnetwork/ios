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
private class AuthVerifyCallback: NSObject, SdkAuthVerifyCallbackProtocol {
    private let completion: (SdkAuthVerifyResult?, Error?) -> Void
    
    init(completion: @escaping (SdkAuthVerifyResult?, Error?) -> Void) {
        self.completion = completion
    }
    
    func result(_ result: SdkAuthVerifyResult?, err: Error?) {
        DispatchQueue.main.async {
            self.completion(result, err)
        }
    }
}

// For resending the OTP
private class AuthVerifySendCallback: NSObject, SdkAuthVerifySendCallbackProtocol {
    private let completion: (SdkAuthVerifySendResult?, Error?) -> Void
    
    init(completion: @escaping (SdkAuthVerifySendResult?, Error?) -> Void) {
        self.completion = completion
    }
    
    func result(_ result: SdkAuthVerifySendResult?, err: Error?) {
        DispatchQueue.main.async {
            self.completion(result, err)
        }
    }
}


extension CreateNetworkVerifyView {
    
    class ViewModel: ObservableObject {
        
        private let api = NetworkSpaceManager.shared.networkSpace?.getApi()
        
        @Published var otp: String = ""
        
        @Published private(set) var isSubmitting: Bool = false
        
        @Published private(set) var isSendingOtp: Bool = false
        
        @Published private(set) var resetBtnEnabled: Bool = true
        
        private var cancellables = Set<AnyCancellable>()
        
        private let domain = "CraeteNetworkVerifyViewModel"
        
        func resendOtp(userAuth: String) async -> Result<Bool, Error> {
            
            if isSendingOtp {
                return .failure(NSError(domain: domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "OTP is already being sent"]))
            }
            
            DispatchQueue.main.async {
                self.isSendingOtp = true
                self.resetBtnEnabled = false
            }
            
            do {
                let result: Bool = try await withCheckedThrowingContinuation { continuation in
                    
                    let callback = AuthVerifySendCallback { [weak self] result, err in
                        guard let self = self else { return }
                        
                        if let err = err {
                            print(err.localizedDescription)
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        continuation.resume(returning: true)
                        
                    }
                    
                    if let api = api {
                        
                        let args = SdkAuthVerifySendArgs()
                        args.userAuth = userAuth
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
        
        func submit(userAuth: String) async -> Result<String, Error> {
            
            
            if isSubmitting {
                return .failure(NSError(domain: domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "OTP is already being sent"]))
            }
            
            isSubmitting = true
            
            do {
                
                let result: String = try await withCheckedThrowingContinuation { continuation in
                    
                    let callback = AuthVerifyCallback { [weak self] result, err in
                        
                        guard let self = self else { return }
                        
                        if let err = err {
                            print(err.localizedDescription)
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        if let result = result {
                            
                            if let resultError = result.error {
                                print(result.error?.message ?? "error unwrapping result.error?.message")

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
                            
                            
                        } else {
                            continuation.resume(throwing: NSError(domain: domain, code: -1, userInfo: [NSLocalizedDescriptionKey: "verify result is nil"]))
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
                self.isSubmitting = false
                return .failure(error)
            }
        }
    }
}
