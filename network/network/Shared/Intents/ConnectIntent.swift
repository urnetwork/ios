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
    
    static let title: LocalizedStringResource = "Connect VPN"
    
    static var isSiriAvailable: Bool = true
    
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    
    // @Parameter(title: location)
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        print("performing action")
        
        // TODO: find the selected location for the device and connect, otherwise connect to best available
        let deviceManager = await DeviceManager()
        
        await deviceManager.waitForDeviceInitialization()
        
        guard let device = await deviceManager.device else {
            print("device is nil")
            print("is device initialized? \(await deviceManager.deviceInitialized)")
            return .result(
                dialog: "Please login to URnetwork to connect"
            )
        }
        
        if device.getConnected() {
            return .result(
                dialog: "You are already connected"
            )
        }
        
        let connected = try await VPNService.shared.connect(device: device)
        
        if connected {
            return .result(dialog: "Connecting to VPN")
        } else {
            return .result(dialog: "Failed to connect")
        }

        
//        guard let connectViewController = device.openConnectViewController() else {
//            return .result(
//                dialog: "Sorry, something went wrong connecting to URnetwork"
//            )
//        }
//        
//        if let connectLocation = device.getConnectLocation() {
//            connectViewController.connect(connectLocation)
//            return .result(
//                // TODO: add provider name to response
//                // dialog: "VPN connected to "
//                dialog: "Connecting VPN to \(connectLocation.name)"
//            )
//        } else {
//            connectViewController.connectBestAvailable()
//            return .result(
//                // TODO: add provider name to response
//                // dialog: "VPN connected to "
//                dialog: "Connecting VPN to the best available location"
//            )
//        }
        
    }
    
}
