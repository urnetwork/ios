//
//  ResetPasswordViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/07.
//

import Foundation
import URnetworkSdk

enum SendPasswordResetError: Error {
    case inProgress
}


extension ResetPasswordView {
    
    class ViewModel: ObservableObject {
        
        private var api: SdkApi
        
        @Published var sendInProgress: Bool = false
        
        let domain = "ResetPasswordViewModel"
        
        init(api: SdkApi) {
            self.api = api
        }
        
        func sendResetLink(_ userAuth: String) async -> Result<Void, Error> {
            
            if sendInProgress {
                return .failure(SendPasswordResetError.inProgress)
            }
            
            DispatchQueue.main.async {
                self.sendInProgress = true
            }
            
            do {
                
                let result: Void = try await withCheckedThrowingContinuation { [weak self] continuation in
                    
                    guard let self = self else { return }
                    
                    let callback = AuthPasswordResetCallback { result, error in
                        
                        if let err = error {
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        guard let result = result else {
                            continuation.resume(throwing: NSError(domain: self.domain, code: -1, userInfo: [NSLocalizedDescriptionKey: "No result found"]))
                            
                            return
                        }
                        
                        return continuation.resume(returning: ())
                        
                    }
                    
                    
                    let args = SdkAuthPasswordResetArgs()
                    args.userAuth = userAuth
                    
                    self.api.authPasswordReset(args, callback: callback)
                    
                }
                
                DispatchQueue.main.async {
                    self.sendInProgress = false
                }
                
                return .success(result)
                
            } catch(let error) {
                return .failure(error)
            }
            
        }
        
    }
    
}

private class AuthPasswordResetCallback: SdkCallback<SdkAuthPasswordResetResult, SdkAuthPasswordResetCallbackProtocol>, SdkAuthPasswordResetCallbackProtocol {
    func result(_ result: SdkAuthPasswordResetResult?, err: Error?) {
        handleResult(result, err: err)
    }
}
