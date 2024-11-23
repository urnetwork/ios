//
//  LoginPasswordViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import Foundation

extension LoginPasswordView {
    
    class ViewModel: ObservableObject {
        
        @Published private(set) var isValid: Bool = false
        
        @Published var password: String = "" {
            didSet {
                isValid = !password.isEmpty
            }
        }
        
    }
}
