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
    var tunnelManager: NETunnelProviderManager?
    
    init(device: SdkBringYourDevice) {
        print("VPN Manager init hit")
        self.device = device
        self.loadOrCreateManager()
    }
    
    private func loadOrCreateManager() {
        // Load all configurations first
        NETunnelProviderManager.loadAllFromPreferences { [weak self] (managers, error) in
            if let error = error {
                print("Error loading managers: \(error.localizedDescription)")
                return
            }
            
            // Use existing manager or create new one
            let manager = managers?.first ?? NETunnelProviderManager()
            self?.tunnelManager = manager
            self?.setup()
        }
    }
    
    func setup() {
        guard let tunnelManager = tunnelManager else { return }
        
        let tunnelProtocol = NETunnelProviderProtocol()
        // Use the same as remote address in PacketTunnelProvider
        // value from connect resolvedHost
        tunnelProtocol.serverAddress = "65.49.70.71"
        tunnelProtocol.providerBundleIdentifier = "com.bringyour.network.extension"
        tunnelProtocol.disconnectOnSleep = false
        
        tunnelManager.protocolConfiguration = tunnelProtocol
        tunnelManager.localizedDescription = "URnetwork"
        tunnelManager.isEnabled = true
        
        tunnelManager.saveToPreferences { [weak self] error in
            if let error = error {
                print("Error saving preferences: \(error.localizedDescription)")
                return
            }
            print("VPN configuration saved successfully")
            self?.addListeners()
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
    
    func connect() {
        
        do {
            
            try self.tunnelManager?.connection.startVPNTunnel()
            print("VPN connection started")
            
        } catch let error as NSError {
            
            print("Error starting VPN connection:")
            print("Domain: \(error.domain)")
            print("Code: \(error.code)")
            print("Description: \(error.localizedDescription)")
            print("User Info: \(error.userInfo)")
            
        }
    }
    
    func disconnect() {
        self.tunnelManager?.connection.stopVPNTunnel()
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
