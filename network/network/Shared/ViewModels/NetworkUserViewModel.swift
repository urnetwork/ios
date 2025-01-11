//
//  NetworkUserViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/11.
//

import Foundation
import URnetworkSdk

@MainActor
class NetworkUserViewModel: ObservableObject {
    
    @Published private(set) var networkUser: SdkNetworkUser?
    
    @Published private(set) var isFetchingNetworkUser: Bool = false
    
    private var api: SdkApi
    
    init(api: SdkApi) {
        self.api = api
        self.initializeNetworkUser()
    }
    
    func initializeNetworkUser() {
        Task {
            await refreshNetworkUser()
        }
    }
    
    func refreshNetworkUser() async -> Result<Void, Error> {
        
        if isFetchingNetworkUser {
            return .failure(FetchNetworkUserError.isFetchingNetworkUser)
        }
        
        isFetchingNetworkUser = true
        
        do {
            let networkUser: SdkNetworkUser = try await withCheckedThrowingContinuation { [weak self] continuation in
            
                guard let self = self else { return }
                
                let callback = GetNetworkUserCallback { result, err in
                    
                    if let err = err {
                        continuation.resume(throwing: err)
                        return
                    }
                    
                    guard let result = result, let networkUser = result.networkUser else {
                        continuation.resume(throwing: SendPasswordResetLinkError.resultInvalid)
                        return
                    }
                    
                    continuation.resume(returning: networkUser)
                    
                }
                
                api.getNetworkUser(callback)
                
            }
            
            DispatchQueue.main.async {
                self.networkUser = networkUser
            }
            
            return .success(())
            
            
        } catch(let error) {
            return .failure(error)
        }
        
    }
    
}

private class GetNetworkUserCallback: SdkCallback<SdkGetNetworkUserResult, SdkGetNetworkUserCallbackProtocol>, SdkGetNetworkUserCallbackProtocol {
    func result(_ result: SdkGetNetworkUserResult?, err: Error?) {
        handleResult(result, err: err)
    }
}

enum FetchNetworkUserError: Error {
    case networkUserNotFound
    case isFetchingNetworkUser
}
