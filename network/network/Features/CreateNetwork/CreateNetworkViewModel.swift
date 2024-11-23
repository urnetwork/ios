//
//  CreateNetworkViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import Foundation

extension CreateNetworkView {
    
    class ViewModel: ObservableObject {
        
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
        
        @Published var password: String = "" {
            didSet {
                validateForm()
            }
        }
        
        @Published private(set) var formIsValid: Bool = false
        
        func setUserAuth(_ ua: String) {
            userAuth = ua
        }

        
        private func validateForm() {
            formIsValid = !userAuth.isEmpty && !networkName.isEmpty && password.count >= 6
        }
        
        private func checkNetworkName() {
            
            // todo - api call to check existing network names
            
            validateForm()
        }
        
    }
    
}
