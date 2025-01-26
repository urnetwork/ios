//
//  ProfileViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import Foundation
import URnetworkSdk

extension ProfileView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        var api: SdkApi
        
        @Published private(set) var isSendingPasswordResetLink: Bool = false
        @Published private(set) var sendPasswordResetLinkError: String?
        
        init(api: SdkApi) {
            self.api = api
        }
        
        func sendPasswordResetLink(_ userAuth: String) async -> Result<Void, Error> {
            
            if isSendingPasswordResetLink {
                return .failure(SendPasswordResetLinkError.isSending)
            }
            
            DispatchQueue.main.async {
                self.isSendingPasswordResetLink = true
            }
                
            do {
                
                let result: SdkAuthPasswordResetResult = try await withCheckedThrowingContinuation { [weak self] continuation in
                
                    guard let self = self else { return }
                    
                    let callback = AuthPasswordResetCallback { result, err in
                        
                        if let err = err {
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        guard let result = result else {
                            continuation.resume(throwing: SendPasswordResetLinkError.resultInvalid)
                            return
                        }
                        
                        continuation.resume(returning: result)
                        
                    }
                    
                    let args = SdkAuthPasswordResetArgs()
                    args.userAuth = userAuth
                    
                    api.authPasswordReset(args, callback: callback)
                    
                }
                   
                DispatchQueue.main.async {
                    self.isSendingPasswordResetLink = false
                }
                
                return .success(())
                
            }
            catch(let error) {
                DispatchQueue.main.async {
                    self.isSendingPasswordResetLink = false
                }
                return .failure(error)
            }

            
        }
        
    }
    
}

enum SendPasswordResetLinkError: Error {
    case isSending
    case resultInvalid
}

private class AuthPasswordResetCallback: SdkCallback<SdkAuthPasswordResetResult, SdkAuthPasswordResetCallbackProtocol>, SdkAuthPasswordResetCallbackProtocol {
    func result(_ result: SdkAuthPasswordResetResult?, err: Error?) {
        handleResult(result, err: err)
    }
}
