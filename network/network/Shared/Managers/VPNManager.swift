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
            vpnProtocol.serverAddress = "" // what should this be set as?
            vpnProtocol.providerBundleIdentifier = "com.bringyour.network.extension"
            vpnProtocol.username = "" // what should this be set as?
            vpnProtocol.passwordReference = self.getPasswordReference() // what do we need a password for?
            vpnProtocol.disconnectOnSleep = false
            
            vpnManager.protocolConfiguration = vpnProtocol
            vpnManager.localizedDescription = "URnetwork"
            vpnManager.isEnabled = true
            
            vpnManager.saveToPreferences { error in
                if let error = error {
                    print("Error saving preferences: \(error.localizedDescription)")
                } else {
                    print("VPN configuration saved successfully")
                }
            }
        }
    }
    
    private func getPasswordReference() -> Data? {
        // Retrieve the password reference from the keychain
        return nil
    }
    
    func connect(with options: [String: NSObject]? = nil) {
        let vpnManager = NEVPNManager.shared()
        
        do {
            try vpnManager.connection.startVPNTunnel(options: options)
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
