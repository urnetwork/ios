//
//  LoginInitialViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/20.
//

import Foundation
import URnetworkSdk


// this LocationsCallback is for testing API calls are working
// temporarily keeping for reference
private class LocationsCallback: NSObject, SdkFindLocationsCallbackProtocol {
    private let completion: (SdkFindLocationsResult?, Error?) -> Void
    
    init(completion: @escaping (SdkFindLocationsResult?, Error?) -> Void) {
        self.completion = completion
    }
    
    func result(_ result: SdkFindLocationsResult?, err: Error?) {
        DispatchQueue.main.async {
            self.completion(result, err)
        }
    }
}

private class AuthLoginCallback: NSObject, SdkAuthLoginCallbackProtocol {
    private let completion: (SdkAuthLoginResult?, Error?) -> Void
    
    init(completion: @escaping (SdkAuthLoginResult?, Error?) -> Void) {
        self.completion = completion
    }
    
    func result(_ result: SdkAuthLoginResult?, err: Error?) {
        DispatchQueue.main.async {
            self.completion(result, err)
        }
    }
}

extension LoginInitialView {
    
    class ViewModel: ObservableObject {
        
        private let api = NetworkSpaceManager.shared.networkSpace?.getApi()
        
        @Published var userAuth: String = "" {
            didSet {
                isValidUserAuth = validateUserAuth()
            }
        }

        @Published private(set) var isValidUserAuth: Bool = false
        
        @Published private(set) var isCheckingUserAuth: Bool = false
        
        @Published private(set) var loginErrorMessage: String?
        
        // Email regex pattern
        private let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        
        // Phone regex pattern (basic international format)
        private let phoneRegex = #"^\+?[1-9]\d{1,14}$"#

        private func isValidEmail(_ string: String) -> Bool {
            string.range(of: emailRegex, options: .regularExpression) != nil
        }
        
        private func isValidPhone(_ string: String) -> Bool {
            string.range(of: phoneRegex, options: .regularExpression) != nil
        }
        
        private func validateUserAuth() -> Bool {
            let trimmedAuth = userAuth.trimmingCharacters(in: .whitespaces)
            return !trimmedAuth.isEmpty &&
                   (isValidEmail(trimmedAuth) || isValidPhone(trimmedAuth))
        }
        
        func getStarted(
            navigateToLogin: @escaping () -> Void,
            navigateToCreateNetwork: @escaping () -> Void
        ) {
            
            if !isValidUserAuth {
                return
            }
            
            isCheckingUserAuth = true
            
            let args = SdkAuthLoginArgs()
            args.userAuth = userAuth
            
            let callback = AuthLoginCallback { [weak self] result, error in
                
                guard let self = self else { return }
                
                if let error {
                    self.loginErrorMessage = error.localizedDescription
                    self.isCheckingUserAuth = false
                    return
                }
                
                if let resultError = result?.error {
                    self.loginErrorMessage = resultError.message
                    self.isCheckingUserAuth = false
                    return
                }
                
                if let authAllowed = result?.authAllowed {
                    
                    if authAllowed.contains("password") {
                        self.loginErrorMessage = nil
                        
                        // login
                        navigateToLogin()
                    } else {
                        print("authAllowed missing password: \(authAllowed)")
                        
                        // todo - localize this
                        self.loginErrorMessage = "An error occurred. Please try again later."
                    }
                    
                    return
                    
                }
                
                // on new network
                navigateToCreateNetwork()
                
            }
            
            api?.authLogin(args, callback: callback)
            
        }
        
        // for testing api
        
//        init() {
//            testApiCall()
//        }
        
//        private func testApiCall() {
//            print("testing api call")
//            
//            
//            let callback = LocationsCallback { [weak self] result, error in
//                
//                guard let self = self else { return }
//                
//                if let error = error {
//                    print("Error: \(error)")
//                    return
//                }
//                
//                guard let result = result else { return }
//                
//                print("we got a result! : \(String(describing: result))")
//                // We can update ViewModel properties from here...
//                // self.locations = result.locations
//                
//            }
//            
//            if (api == nil) {
//                print("api is nil!")
//                return
//            }
//            
//            api?.getProviderLocations(callback)
//            
//        }
        
    }
}
