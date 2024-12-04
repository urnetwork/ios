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
    case login(SdkAuthLoginResult)
    case create(SdkAuthLoginArgs)
    case failure(Error)
}
