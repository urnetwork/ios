//
//  LoginInitialViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/20.
//

import Foundation

extension LoginInitialView {
    
    class ViewModel: ObservableObject {
        
        @Published var userAuth: String = "" {
            didSet {
                isValidUserAuth = validateUserAuth()
            }
        }

        @Published private(set) var isValidUserAuth: Bool = false
        
        // @Published private(set) var navigationPath: LoginInitialNavigationPath?
        
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
        
//        func navigate() {
//            print("navigate hit")
//            navigationPath = .password(userAuth)
//        }
        
        
    }
}
