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
private class LocationsCallback: NSObject, URnetworkSdk.SdkFindLocationsCallbackProtocol {
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

extension LoginInitialView {
    
    class ViewModel: ObservableObject {
        
        private let api = NetworkSpaceManager.shared.networkSpace?.getApi()
        
        @Published var userAuth: String = "" {
            didSet {
                isValidUserAuth = validateUserAuth()
            }
        }

        @Published private(set) var isValidUserAuth: Bool = false
        
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
        
        // for testing api
        
        init() {
            testApiCall()
        }
        
        private func testApiCall() {
            print("testing api call")
            
            
            let callback = LocationsCallback { [weak self] result, error in
                
                guard let self = self else { return }
                
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                guard let result = result else { return }
                
                print("we got a result! : \(String(describing: result))")
                // We can update ViewModel properties from here...
                // self.locations = result.locations
                
            }
            
            if (api == nil) {
                print("api is nil!")
                return
            }
            
            api?.getProviderLocations(callback)
            
        }
        
    }
}
