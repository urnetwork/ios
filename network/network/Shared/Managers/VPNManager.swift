//
//  VPNManager.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/20.
//

import Foundation
import NetworkExtension
import URnetworkSdk

class VPNManager {
    
    var device: SdkBringYourDevice
    var tunnelManager: NETunnelProviderManager
    
    init(device: SdkBringYourDevice) {
        self.device = device
        self.tunnelManager = NETunnelProviderManager()
    }
    
    func setup() {
        
        tunnelManager.loadFromPreferences { error in
            if let error = error {
                print("Error loading preferences: \(error.localizedDescription)")
                return
            }
            
            let vpnProtocol = NETunnelProviderProtocol()
            vpnProtocol.serverAddress = "ur.io" // what should this be set as?
            vpnProtocol.providerBundleIdentifier = "com.bringyour.network.extension"
            // vpnProtocol.username = "hello_world" // what should this be set as?
            // vpnProtocol.passwordReference = self.getPasswordReference() // what do we need a password for?
            vpnProtocol.disconnectOnSleep = false
            
            self.tunnelManager.protocolConfiguration = vpnProtocol
            self.tunnelManager.localizedDescription = "URnetwork"
            self.tunnelManager.isEnabled = true
            
            self.tunnelManager.saveToPreferences { error in
                if let error = error {
                    print("Error saving preferences: \(error.localizedDescription)")
                } else {
                    print("VPN configuration saved successfully")
                    self.addListeners()
                }
            }
        }
    }
    
    func addListeners() {
        
        let connectChangeListener = ConnectChangedListener { [weak self] connectEnabled in
            
            guard let self = self else { return }
            
            print("connect changed: \(connectEnabled)")
            self.updateVpnService()
            
        }
        
        device.add(connectChangeListener)
    }
    
    private func updateVpnService() {
        
        print("update vpn service hit")
        let provideEnabled = device.getProvideEnabled()
        let providePaused = device.getProvidePaused()
        let connectEnabled = device.getConnectEnabled()
        let routeLocal = device.getRouteLocal()
        
        if (provideEnabled || connectEnabled || !routeLocal) {
            print("start vpn")
            
            // TODO: handle wakelock & wifi lock
            self.connect()
            
        } else {
            
            print("stop vpn")
            self.disconnect()
            
        }
        
        
    }
    
    private func getPasswordReference() -> Data? {
        // Retrieve the password reference from the keychain
        return nil
    }
    
    func connect(
        // with options: [String: NSObject]? = nil
    ) {
        var options: [String: NSObject] = [:]
        options["device"] = device
        
        do {
            try tunnelManager.connection.startVPNTunnel(options: options)
            print("VPN connection started")
        } catch {
            print("Error starting VPN connection: \(error.localizedDescription)")
        }
    }
    
    func disconnect() {
        tunnelManager.connection.stopVPNTunnel()
        print("VPN connection stopped")
    }
    
}

private class ConnectChangedListener: NSObject, SdkConnectChangeListenerProtocol {
    
    private let callback: (_ connectEnabled: Bool) -> Void

    init(callback: @escaping (_ connectEnabled: Bool) -> Void) {
        self.callback = callback
    }
    
    func connectChanged(_ connectEnabled: Bool) {
        callback(connectEnabled)
    }
}
