//
//  PayoutWalletViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/18.
//

import Foundation
import URnetworkSdk

private class FetchPayoutWalletCallback: SdkCallback<SdkGetPayoutWalletIdResult, SdkGetPayoutWalletCallbackProtocol>, SdkGetPayoutWalletCallbackProtocol {
    func result(_ result: SdkGetPayoutWalletIdResult?, err: Error?) {
        handleResult(result, err: err)
    }
}


@MainActor
class PayoutWalletViewModel: ObservableObject {
    
    var api: SdkBringYourApi?
    let domain = "[PayoutWalletViewModel]"
    
    @Published private(set) var payoutWalletId: SdkId?
    var isFetchingPayoutWallet: Bool = false
    
    init(api: SdkBringYourApi?) {
        self.api = api
        self.initPayoutWallet()
    }
    
    private func initPayoutWallet() {
        Task {
            await fetchPayoutWallet()
        }
    }
    
    private func fetchPayoutWallet() async {
        
        if isFetchingPayoutWallet {
            return
        }
        
        isFetchingPayoutWallet = true
        
        do {
            
            let result: SdkGetPayoutWalletIdResult = try await withCheckedThrowingContinuation { [weak self] continuation in
                
                guard let self = self else { return }
                
                let callback = FetchPayoutWalletCallback { result, err in
                    
                    if let err = err {
                        continuation.resume(throwing: err)
                        return
                    }
                    
                    guard let result = result else {
                        continuation.resume(throwing: NSError(domain: self.domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "FetchPayoutWalletCallback result is nil"]))
                        return
                    }
                    
                    continuation.resume(returning: result)
                    
                }
                
                api?.getPayoutWallet(callback)
                
            }
            
            if let payoutWalletId = result.walletId {
                self.payoutWalletId = payoutWalletId
            }
            
            isFetchingPayoutWallet = false
            
        } catch(let error) {
            print("\(domain) Error fetching payout wallet: \(error)")
            isFetchingPayoutWallet = false
        }
        
    }
    
    func updatePayoutWallet(_ walletId: SdkId) {
        
    }
    
}
