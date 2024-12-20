//
//  AppProxyProvider.swift
//  extension
//
//  Created by brien on 11/18/24.
//

import NetworkExtension

class AppProxyProvider: NEAppProxyProvider {

    override func startProxy(options: [String : Any]? = nil, completionHandler: @escaping (Error?) -> Void) {
        // Add code here to start the process of connecting the tunnel.
        configureNetworkSettings()
        completionHandler(nil)
    }
    
    override func stopProxy(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping() -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
    
    override func handleNewFlow(_ flow: NEAppProxyFlow) -> Bool {
        // Add code here to handle the incoming flow.
        return false
    }
    
    private func configureNetworkSettings() {
        let tunnelNetworkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "")
        
        // Configure IP settings
        let ipv4Settings = NEIPv4Settings(addresses: [], subnetMasks: [])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        
        // Add custom routes
        let customRoutes: [NEIPv4Route] = [
            // Add routes as needed
        ]
        ipv4Settings.includedRoutes?.append(contentsOf: customRoutes)
        
        tunnelNetworkSettings.ipv4Settings = ipv4Settings
        
        // Configure DNS settings
        let dnsSettings = NEDNSSettings(servers: [])
        tunnelNetworkSettings.dnsSettings = dnsSettings
        
        // Apply the network settings
        setTunnelNetworkSettings(tunnelNetworkSettings) { error in
            if let error = error {
                print("Error setting tunnel network settings: \(error.localizedDescription)")
            } else {
                print("Tunnel network settings applied successfully")
            }
        }
    }
}
