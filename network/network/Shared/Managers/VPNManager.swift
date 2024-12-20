//
//  VPNManager.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/20.
//

import Foundation
import NetworkExtension

class VPNManager {
    
    static let shared = VPNManager()
    
    private init() {}
    
    func setup() {
        let vpnManager = NEVPNManager.shared()
        
        vpnManager.loadFromPreferences { error in
            if let error = error {
                print("Error loading preferences: \(error.localizedDescription)")
                return
            }
            
            let vpnProtocol = NETunnelProviderProtocol()
            
            
            
        }
    }
    
    func connect() {
        let vpnManager = NEVPNManager.shared()
        
        do {
            try vpnManager.connection.startVPNTunnel()
            print("VPN connection started")
        } catch {
            print("Error starting VPN connection: \(error.localizedDescription)")
        }
    }
    
    func disconnect() {
        let vpnManager = NEVPNManager.shared()
        vpnManager.connection.stopVPNTunnel()
        print("VPN connection stopped")
    }
    
}
