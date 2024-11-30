//
//  LoginNetworkResult.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/29.
//

import Foundation

enum LoginNetworkResult {
    case successWithJwt(String)
    case successWithVerificationRequired
    case failure(Error)
}
