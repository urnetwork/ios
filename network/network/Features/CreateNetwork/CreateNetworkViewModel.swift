//
//  CreateNetworkViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import Foundation
import URnetworkSdk


private class NetworkCheckCallback: NSObject, SdkNetworkCheckCallbackProtocol {
    
    private let completion: (SdkNetworkCheckResult?, Error?) -> Void
    
    init(completion: @escaping (SdkNetworkCheckResult?, Error?) -> Void) {
        self.completion = completion
    }
    
    func result(_ result: SdkNetworkCheckResult?, err: (any Error)?) {
        DispatchQueue.main.async {
            self.completion(result, err)
        }
    }
    
}

extension CreateNetworkView {
    
    class ViewModel: ObservableObject {
        
        private let api = NetworkSpaceManager.shared.networkSpace?.getApi()
        private var networkNameValidationVc: SdkNetworkNameValidationViewController?
        
        init() {
            if let api = api {
                networkNameValidationVc = SdkNetworkNameValidationViewController(api)
            }
        }
        
        @Published var userAuth: String = "" {
            didSet {
                validateForm()
            }
        }
        
        @Published var networkName: String = "" {
            didSet {
                checkNetworkName()
            }
        }
        
        @Published var isNetworkNameValid: Bool = false
        
        @Published private(set) var isCheckingNetworkName: Bool = false
        
        @Published var password: String = "" {
            didSet {
                validateForm()
            }
        }
        
        @Published private(set) var formIsValid: Bool = false
        
        // for debouncing calls to check network name availability
        private var networkCheckWorkItem: DispatchWorkItem?
        
        func setUserAuth(_ ua: String) {
            userAuth = ua
        }

        
        private func validateForm() {
            formIsValid = !userAuth.isEmpty && !networkName.isEmpty && password.count >= 6
        }
        
        private func checkNetworkName() {
            
            networkCheckWorkItem?.cancel()
            
            if networkName.count < 6 {
                return
            }
            
            if let networkNameValidationVc = networkNameValidationVc {
                
                isCheckingNetworkName = true
                
                let callback = NetworkCheckCallback { [weak self] result, error in
                    
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("error checking network name: \(error.localizedDescription)")
                        return
                    }
                    
                    if let result = result {
                        print("result checking network name \(networkName): \(result.available)")
                        self.isNetworkNameValid = result.available
                    }
                    
                    validateForm()
                    
                    self.isCheckingNetworkName = false
            
                }
                
                networkCheckWorkItem = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    
                    self.networkNameValidationVc?.networkCheck(networkName, callback: callback)
                }
                
                if let workItem = networkCheckWorkItem {
                    // delay .5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem)
                }
                
            }
            
        }
        
    }
    
}
