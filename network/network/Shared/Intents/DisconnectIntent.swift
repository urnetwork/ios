//
//  DisconnectIntent.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/17.
//

import Foundation
import AppIntents
import URnetworkSdk

struct DisconnectIntent: AppIntent {
    
    static let title: LocalizedStringResource = "Disconnect URnetwork VPN"
    
    static var isSiriAvailable: Bool = true
    
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    
    // @Parameter(title: location)
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        let deviceManager = await DeviceManager()
        
        await deviceManager.waitForDeviceInitialization()
        
        guard let device = await deviceManager.device else {
            return .result(
                dialog: "Please login to URnetwork to connect"
            )
        }
        
        if !device.getConnected() {
            return .result(
                dialog: "You are already disconnected"
            )
        }
        
        let disconnected = try await VPNService.shared.disconnect()
        
        if disconnected {
            return .result(dialog: "Disconnecting from URnetwork")
        } else {
            return .result(dialog: "Failed to disconnect")
        }
        
    }
    
}
