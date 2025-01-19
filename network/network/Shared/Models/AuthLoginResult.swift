//
//  AuthLoginResult.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/04.
//

import Foundation
import URnetworkSdk

// NOTE: used in LoginInitial to check whether the user already exists or if they should create a new network
enum AuthLoginResult {
    case login(String) // JWT
    case promptPassword(SdkAuthLoginResult)
    case create(SdkAuthLoginArgs)
    case failure(Error)
}

enum AuthLoginError: Error {
    case isInProgress
    case invalidResult
    case invalidArguments
    
}
