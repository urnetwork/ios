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
    
    // @Parameter(title: location)
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        print("performing action")
        
        // TODO: find the selected location for the device and connect, otherwise connect to best available
        let deviceManager = await DeviceManager()
        
        await deviceManager.waitForDeviceInitialization()
        
//        let device = await deviceManager.device
//        if device == nil {
//            print("is device initialized? \(await deviceManager.deviceInitialized)")
//            print("device is nil")
//            return .result(
//                dialog: "Device is nil. Please login to URnetwork to connect"
//            )
//        }
        
        guard let device = await deviceManager.device else {
            print("device is nil")
            print("is device initialized? \(await deviceManager.deviceInitialized)")
            return .result(
                dialog: "Please login to URnetwork to connect"
            )
        }
        
        let _ = VPNManager(device: device)
        
        if device.getConnected() {
            return .result(
                dialog: "You are already connected"
            )
        }
        
        guard let connectViewController = device.openConnectViewController() else {
            return .result(
                dialog: "Sorry, something went wrong connecting to URnetwork"
            )
        }
        
        if let connectLocation = device.getConnectLocation() {
            connectViewController.connect(connectLocation)
            return .result(
                // TODO: add provider name to response
                // dialog: "VPN connected to "
                dialog: "Connecting VPN to \(connectLocation.name)"
            )
        } else {
            connectViewController.connectBestAvailable()
            return .result(
                // TODO: add provider name to response
                // dialog: "VPN connected to "
                dialog: "Connecting VPN to the best available location"
            )
        }
        
    }
    
}
