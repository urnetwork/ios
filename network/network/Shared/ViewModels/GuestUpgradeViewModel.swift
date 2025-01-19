//
//  GuestUpgradeViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/19.
//

import Foundation
import URnetworkSdk

@MainActor
class GuestUpgradeViewModel: ObservableObject {
    
    @Published private(set) var isUpgrading: Bool = false
    
    private var api: SdkApi
    
    let domain = "[GuestUpgradeViewModel]"
    
    init(isUpgrading: Bool, api: SdkApi) {
        self.api = api
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
                
                api.upgradeGuestExisting(upgradeArgs, callback: callback)
                
            }
            
            return result
            
        } catch(let error) {
            return .failure(error)
        }
        
    }
    
}

private class UpgradeGuestExistingCallback: SdkCallback<SdkUpgradeGuestExistingResult, SdkUpgradeGuestExistingCallbackProtocol>, SdkUpgradeGuestExistingCallbackProtocol {
    func result(_ result: SdkUpgradeGuestExistingResult?, err: Error?) {
        handleResult(result, err: err)
    }
}
