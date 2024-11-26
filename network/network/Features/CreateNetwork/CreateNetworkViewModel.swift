//
//  CreateNetworkViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import Foundation
import URnetworkSdk
import SwiftUICore


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
        
        private static let networkNameTooShort: LocalizedStringKey = "Network names must be 6 characters or more"
        private static let networkNameUnavailable: LocalizedStringKey = "This network name is already taken"
        private static let networkNameCheckError: LocalizedStringKey = "There was an error checking the network name"
        private static let networkNameAvailable: LocalizedStringKey = "Nice! This network name is available"
        
        private static let minPasswordLength = 12
        
        @Published var userAuth: String = "" {
            didSet {
                validateForm()
            }
        }
        
        @Published var networkName: String = "" {
            didSet {
                if oldValue != networkName {
                    checkNetworkName()
                }
            }
        }
        
        @Published private(set) var networkNameValidationState: ValidationState = .notChecked
        
        
        @Published var password: String = "" {
            didSet {
                validateForm()
            }
        }
        
        @Published private(set) var formIsValid: Bool = false
        
        @Published private(set) var networkNameSupportingText: LocalizedStringKey = ""
        
        @Published var termsAgreed: Bool = false {
            didSet {
                validateForm()
            }
        }
        
        init() {
            if let api = api {
                networkNameValidationVc = SdkNetworkNameValidationViewController(api)
            }
            
            setNetworkNameSupportingText(ViewModel.networkNameTooShort)
        }
        
        private func setNetworkNameSupportingText(_ text: LocalizedStringKey) {
            networkNameSupportingText = text
        }
        
        // for debouncing calls to check network name availability
        private var networkCheckWorkItem: DispatchWorkItem?
        
        func setUserAuth(_ ua: String) {
            userAuth = ua
        }

        
        private func validateForm() {
            formIsValid = ValidationUtils.isValidUserAuth(userAuth) &&
                            networkNameValidationState == .valid &&
                            password.count >= ViewModel.minPasswordLength &&
                            termsAgreed
        }
        
        private func checkNetworkName() {
            
            networkCheckWorkItem?.cancel()
            
            if networkName.count < 6 {
                
                if networkNameSupportingText != ViewModel.networkNameTooShort {
                    setNetworkNameSupportingText(ViewModel.networkNameTooShort)
                }
    
                return
            }
            
            networkNameValidationState = .validating
            
            if networkNameValidationVc != nil {
                
                let callback = NetworkCheckCallback { [weak self] result, error in
                    
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("error checking network name: \(error.localizedDescription)")
                        setNetworkNameSupportingText(ViewModel.networkNameCheckError)
                        self.networkNameValidationState = .invalid
                        validateForm()
                        
                        return
                    }
                    
                    if let result = result {
                        print("result checking network name \(networkName): \(result.available)")
                        self.networkNameValidationState = result.available ? .valid : .invalid
                        
                        
                        if (result.available) {
                            setNetworkNameSupportingText(ViewModel.networkNameAvailable)
                        } else {
                            setNetworkNameSupportingText(ViewModel.networkNameUnavailable)
                        }
                    }
                    
                    validateForm()
            
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
