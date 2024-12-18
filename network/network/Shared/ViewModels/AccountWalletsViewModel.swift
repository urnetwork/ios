//
//  WalletsViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/15.
//

import Foundation
import URnetworkSdk

private class TransferStatsCallback: SdkCallback<SdkTransferStatsResult, SdkGetTransferStatsCallbackProtocol>, SdkGetTransferStatsCallbackProtocol {
    func result(_ result: SdkTransferStatsResult?, err: Error?) {
        handleResult(result, err: err)
    }
}

private class GetAccountWalletsCallback: SdkCallback<SdkGetAccountWalletsResult, SdkGetAccountWalletsCallbackProtocol>, SdkGetAccountWalletsCallbackProtocol {
    func result(_ result: SdkGetAccountWalletsResult?, err: Error?) {
        handleResult(result, err: err)
    }
}

@MainActor
class AccountWalletsViewModel: ObservableObject {
    
    let domain = "[AccountWalletsViewModel]"
    @Published private(set) var wallets: [SdkAccountWallet] = []
    @Published private(set) var isLoadingTransferStats: Bool = false
    @Published private(set) var isLoadingAccountWallets: Bool = false
    @Published private(set) var isCreatingExternalWallet: Bool = false
    
    @Published private(set) var unpaidMegaBytes: String = ""
    
    var api: SdkBringYourApi?
    
    init(api: SdkBringYourApi?) {
        self.api = api
        self.fetchAccountWallets()
        self.fetchTransferStats()
    }
    
    func fetchAccountWallets() {
        
        if isLoadingAccountWallets {
            return
        }
        
        isLoadingAccountWallets = true
        
        Task {
            
            do {
                let result: SdkGetAccountWalletsResult = try await withCheckedThrowingContinuation { [weak self] continuation in
                    
                    guard let self = self else { return }
                    
                    let callback = GetAccountWalletsCallback { result, err in
                        
                        if let err = err {
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        guard let result = result else {
                            continuation.resume(throwing: NSError(domain: self.domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "SdkGetAccountWalletsResult result is nil"]))
                            return
                        }
                        
                        continuation.resume(returning: result)
                        
                    }
                    
                    api?.getAccountWallets(callback)
                }
                
                wallets = handleAccountWalletsList(result)
                isLoadingAccountWallets = false
                
            } catch(let error) {
                print("\(domain) Error fetching account wallets: \(error)")
                isLoadingAccountWallets = false
            }
            
        }
        
    }
    
    private func handleAccountWalletsList(_ result: SdkGetAccountWalletsResult) -> [SdkAccountWallet] {

        guard let walletsList = result.wallets else { return [] }
        
        var accountWallets: [SdkAccountWallet] = []
        let n = walletsList.len()
        
        for i in 0..<n {
            let wallet = walletsList.get(i)
            
            if let wallet = wallet {
                accountWallets.append(wallet)
            }
        }
        
        return accountWallets
        
    }
    
    /**
     * Fetch unpaid bytes provided
     */
    func fetchTransferStats() {
        
        if isLoadingTransferStats {
            return
        }
        
        isLoadingTransferStats = true
        
        Task {
         
            do {
                
                let result: SdkTransferStatsResult = try await withCheckedThrowingContinuation { [weak self] continuation in
                    
                    guard let self = self else { return }
                    
                    let callback = TransferStatsCallback { result, err in
                        
                        if let err = err {
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        guard let result = result else {
                            continuation.resume(throwing: NSError(domain: self.domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "TransferStatsCallback result is nil"]))
                            return
                        }
                        
                        continuation.resume(returning: result)
                    }
                    
                    api?.getTransferStats(callback)
                    
                }
                
                let unpaidBytes = result.unpaidBytesProvided
                unpaidMegaBytes = String(format: "%.2f MB", Double(unpaidBytes) / 1_048_576) // 1 MB = 1,048,576 bytes
                isLoadingTransferStats = false
                
            } catch(let error) {
                print("\(domain) Error fetching transfer stats: \(error)")
                isLoadingTransferStats = false
            }
            
        }
        
    }
    
}
