//
//  AccountPreferencesViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/14.
//

import Foundation
import URnetworkSdk

private class GetAccountPreferencesCallback: SdkCallback<SdkAccountPreferencesGetResult, SdkAccountPreferencesGetCallbackProtocol>, SdkAccountPreferencesGetCallbackProtocol {
    func result(_ result: SdkAccountPreferencesGetResult?, err: Error?) {
        handleResult(result, err: err)
    }
}

private class UpdateAccountPreferencesCallback: SdkCallback<SdkAccountPreferencesSetResult, SdkAccountPreferencesSetCallbackProtocol>, SdkAccountPreferencesSetCallbackProtocol {
    func result(_ result: SdkAccountPreferencesSetResult?, err: Error?) {
        handleResult(result, err: err)
    }
}

@MainActor
class AccountPreferencesViewModel: ObservableObject {
    
    @Published var canReceiveProductUpdates: Bool = false {
        
        didSet {
            self.updateAccountPreferences(canReceiveProductUpdates)
        }
        
    }
    
    @Published var isUpdatingAccountPreferences: Bool = false
    
    let domain = "AccountPreferencesViewModel"
    
    var api: SdkApi?
    
    init(api: SdkApi?) {
        self.api = api
        self.fetchAccountPreferences()
    }
    
    private func fetchAccountPreferences() {
        
        Task {
        
            do {
                
                let result: SdkAccountPreferencesGetResult = try await withCheckedThrowingContinuation { [weak self] continuation in
                  
                    guard let self = self else { return }
                    
                    let callback = GetAccountPreferencesCallback { result, err in
                        
                        if let err = err {
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        guard let result = result else {
                            continuation.resume(throwing: NSError(domain: self.domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "AccountPreferencesGetCallback result is nil"]))
                            return
                        }
                        
                        continuation.resume(returning: result)
                        return
                    }
                    
                    api?.accountPreferencesGet(callback)
                }
                
                self.canReceiveProductUpdates = result.productUpdates
                print("canReceiveProductUpdates: \(result.productUpdates)")
                
            } catch(let error) {
                print("[\(domain)] Error fetching account preferences: \(error)")
            }
            
        }
        
    }
    
    func updateAccountPreferences(_ allowUpdates: Bool) {
        
        if (isUpdatingAccountPreferences) {
            return
        }
        
        isUpdatingAccountPreferences = true
        
        Task {
         
            do {
                
                let _: SdkAccountPreferencesSetResult = try await withCheckedThrowingContinuation { [weak self] continuation in
                    
                    guard let self = self else { return }
                    
                    let callback = UpdateAccountPreferencesCallback { result, err in
                        
                        if let err = err {
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        guard let result = result else {
                            continuation.resume(throwing: NSError(domain: self.domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "UpdateAccountPreferencesCallback result is nil"]))
                            return
                        }
                        
                        continuation.resume(returning: result)
                        return
                    }
                    
                    let args = SdkAccountPreferencesSetArgs()
                    args.productUpdates = allowUpdates
                    
                    api?.accountPreferencesUpdate(args, callback: callback)
                    
                }
                
                isUpdatingAccountPreferences = false
                
            } catch(let error) {
                
                print("[\(domain)] error updating account preferences: \(error.localizedDescription)")
                
                isUpdatingAccountPreferences = false
            }
            
        }
        
    }
    
}
