//
//  VPNService.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/17.
//

import Foundation
import NetworkExtension
import URnetworkSdk

/**
 * This is used in our Intents to keep a VPN Manager alive
 */
@MainActor
final class VPNService {
    
    static let shared = VPNService()
    private var vpnManager: VPNManager?
    
    private init() {}
    
    func connect(device: SdkDeviceRemote) async throws -> Bool {
        
        vpnManager = VPNManager(device: device)
        
        guard let connectViewController = device.openConnectViewController() else {
            return false
        }
        
        if let connectLocation = device.getConnectLocation() {
            connectViewController.connect(connectLocation)
        } else {
            connectViewController.connectBestAvailable()
        }
        
        return true
    }
    
    func disconnect() {
        vpnManager?.close()
        vpnManager = nil
    }
    
}
