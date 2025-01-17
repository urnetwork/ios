//
//  ConnectIntent.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/16.
//

import Foundation
import AppIntents
import URnetworkSdk

struct ConnectIntent: AppIntent {
    
    static let title: LocalizedStringResource = "Connect URnetwork VPN"
    
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
        
        if device.getConnected() {
            return .result(
                dialog: "You are already connected"
            )
        }
        
        // let connected = try await VPNService.shared.connect(device: device)
//        guard let vpnManager = await deviceManager.vpnManager else {
//            return .result(dialog: "Failed to connect")
//        }
        
        guard let connectViewController = device.openConnectViewController() else {
            return .result(dialog: "Failed to connect")
        }
        
        // self.connectViewController = connectViewController
        
        if let location = device.getConnectLocation() {
            connectViewController.connect(location)
        } else {
            connectViewController.connectBestAvailable()
        }
        
        return .result(dialog: "Connecting to URnetwork")
        
//        if connected {
//            return .result(dialog: "Connecting to URnetwork")
//        } else {
//            return .result(dialog: "Failed to connect")
//        }
//        
    }
    
}
