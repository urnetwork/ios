//
//  ConnectExternalWalletSheetViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/17.
//

import Foundation
import URnetworkSdk
import Combine

private class CreateAccountWalletCallback: SdkCallback<SdkCreateAccountWalletResult, SdkCreateAccountWalletCallbackProtocol>, SdkCreateAccountWalletCallbackProtocol {
    func result(_ result: SdkCreateAccountWalletResult?, err: Error?) {
        handleResult(result, err: err)
    }
}

private class ValidateAddressCallback: SdkCallback<SdkWalletValidateAddressResult, SdkWalletValidateAddressCallbackProtocol>, SdkWalletValidateAddressCallbackProtocol {
    func result(_ result: SdkWalletValidateAddressResult?, err: Error?) {
        handleResult(result, err: err)
    }
}

enum ValidateAddressError: Error {
    case invalidLength
}

enum CreateWalletError: Error {
    case isLoading
    case invalidChain
    case invalidAddress
}

enum WalletChain: String {
    case sol = "SOL"
    case matic = "MATIC"
    case invalid = "INVALID"
}

extension ConnectExternalWalletSheetView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        @Published var walletAddress: String = ""
        @Published var isCreatingWallet: Bool = false
        @Published var isValidWalletAddress: Bool = false
        @Published var chain = WalletChain.invalid
        let domain = "[ConnectExternalWalletSheetViewModel]"
        
        private var cancellables = Set<AnyCancellable>()
        private var debounceTimer: AnyCancellable?
        
        var api: SdkBringYourApi?
        
        init(api: SdkBringYourApi?) {
            self.api = api
            
            
            // when wallet address changes
            // debounce and fire validation
            $walletAddress
                .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                .sink { [weak self] address in
                    self?.validateAddress(address)
                }
                .store(in: &cancellables)
            
        }
        
        private func validateAddress(_ address: String) {
            Task {
                async let solanaValidation = validateAddress(address, chain: "SOL")
                async let maticValidation = validateAddress(address, chain: "MATIC")
                
                let (solanaResult, polygonResult) = await (solanaValidation, maticValidation)
                
                switch (solanaResult, polygonResult) {
                case (.success(let isSolanaValid), .success(let isPolygonValid)):
                    
                    if isSolanaValid {
                        self.chain = WalletChain.sol
                        self.isValidWalletAddress = true
                    } else if isPolygonValid {
                        self.chain = WalletChain.matic
                        self.isValidWalletAddress = true
                    } else {
                        self.chain = WalletChain.invalid
                        self.isValidWalletAddress = false
                    }
                    
                default:
                    print("\(domain) validation failed")
                    self.chain = WalletChain.invalid
                    self.isValidWalletAddress = false
                
                }
                print("is valid wallet address: \(isValidWalletAddress)")
                print("chain is \(chain)")
            }
        }
        
        private func validateAddress(_ address: String, chain: String) async -> Result<Bool, Error> {
            
            if walletAddress.count < 42 {
                return .failure(ValidateAddressError.invalidLength)
            }
            
            do {
                
                let isValid: Bool = try await withCheckedThrowingContinuation { [weak self] continuation in
                    
                    guard let self = self else { return }
                    
                    let callback = ValidateAddressCallback { result, err in
                        
                        if let err = err {
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        guard let result = result else {
                            continuation.resume(throwing: NSError(domain: self.domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "SdkCreateAccountWalletResult result is nil"]))
                            return
                        }
                        
                        continuation.resume(returning: result.valid)
                    }
                    
                    let args = SdkWalletValidateAddressArgs()
                    args.address = address
                    args.chain = chain
                    
                    api?.walletValidateAddress(args, callback: callback)
                }
                
                return .success(isValid)
                
            } catch(let error) {
                print("error validating address on chain \(chain): \(error)")
                return .failure(error)
            }
            
        }
        
        func createExternalWallet() async -> Result<Void, Error> {
            
            if isCreatingWallet {
                return .failure(CreateWalletError.isLoading)
            }
            
            if chain == .invalid {
                return .failure(CreateWalletError.invalidChain)
            }
            
            if !isValidWalletAddress {
                return .failure(CreateWalletError.invalidAddress)
            }
            
            isCreatingWallet = true
            
            do {
                
                let result: SdkCreateAccountWalletResult = try await withCheckedThrowingContinuation { [weak self] continuation in
                    
                    guard let self = self else { return }
                    
                    let callback = CreateAccountWalletCallback { result, err in
                        
                        if let err = err {
                            continuation.resume(throwing: err)
                            return
                        }
                        
                        guard let result = result else {
                            continuation.resume(throwing: NSError(domain: self.domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "SdkCreateAccountWalletResult result is nil"]))
                            return
                        }
                        
                        continuation.resume(returning: result)
                    }
                    
                    let args = SdkCreateAccountWalletArgs()
                    args.blockchain = chain.rawValue
                    args.walletAddress = walletAddress
                    
                    api?.createAccountWallet(args, callback: callback)
                }
                
                isCreatingWallet = false
                // self.fetchAccountWallets()
                return .success(())
                
            } catch(let error) {
                isCreatingWallet = false
                return .failure(error)
            }
            
        }
        
    }
    
}
