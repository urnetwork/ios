//
//  ValidationUtils.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/26.
//

import Foundation

class ValidationUtils {
 
    // Email regex pattern
    static private let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

    // Phone regex pattern (basic international format)
    static private let phoneRegex = #"^\+?[1-9]\d{1,14}$"#

    static func isValidEmail(_ string: String) -> Bool {
        return string.range(of: emailRegex, options: .regularExpression) != nil
    }

    static func isValidPhone(_ string: String) -> Bool {
        return string.range(of: phoneRegex, options: .regularExpression) != nil
    }

    static func isValidUserAuth(_ userAuth: String) -> Bool {
        let trimmedAuth = userAuth.trimmingCharacters(in: .whitespaces)
        return !trimmedAuth.isEmpty &&
               (isValidEmail(trimmedAuth) || isValidPhone(trimmedAuth))
    }
}
