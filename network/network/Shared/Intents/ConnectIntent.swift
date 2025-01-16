//
//  ConnectIntent.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/16.
//

import Foundation
import AppIntents

struct ConnectVPN: AppIntent {
    
    static let title: LocalizedStringResource = "Connect VPN"
    
    // @Parameter(title: location)
    
    func perform() async throws -> some IntentResult {
        
        // TODO: find the selected location for the device and connect, otherwise connect to best available
        
        return .result()
        
    }
    
}
