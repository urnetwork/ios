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
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        let deviceManager = await DeviceManager()
        
        await deviceManager.waitForDeviceInitialization()
        
        guard let device = await deviceManager.device else {
            return .result(
                dialog: "Please login to URnetwork"
            )
        }
        
        if !device.getConnected() {
            return .result(
                dialog: "You are disconnected"
            )
        }
        
        guard let connectViewController = device.openConnectViewController() else {
            return .result(dialog: "Failed to connect")
        }
        
        connectViewController.disconnect()
        
        return .result(dialog: "URnetwork VPN disconnected")
         
    }
    
}
