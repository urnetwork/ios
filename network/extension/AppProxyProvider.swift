//
//  AppProxyProvider.swift
//  extension
//
//  Created by brien on 11/18/24.
//

import NetworkExtension
import URnetworkSdk

class AppProxyProvider: NEAppProxyProvider {
    
    var device: SdkBringYourDevice?
    var active = true

    override func startProxy(options: [String : Any]? = nil, completionHandler: @escaping (Error?) -> Void) {
        // Add code here to start the process of connecting the tunnel.
        
        if let options = options, let device = options["device"] as? SdkBringYourDevice {
            self.device = device
        }
        
        configureNetworkSettings()
        completionHandler(nil)
    }
    
    override func stopProxy(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        
        active = false
        
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
        
        guard active else { return false }
        
        if let tcpFlow = flow as? NEAppProxyTCPFlow {
            handleTCPFlow(tcpFlow)
            return true
        } else if let udpFlow = flow as? NEAppProxyUDPFlow {
            handleUDPFlow(udpFlow)
            return true
        }
        
        return false
    }
    
    private func handleTCPFlow(_ flow: NEAppProxyTCPFlow) {
        let queue = DispatchQueue(label: "TCPFlowQueue")
        queue.async {
            let readBuffer = NSMutableData()
            flow.readData { data, error in
                if let data = data {
                    readBuffer.append(data)
                    // Process the data and send it to BringYourDevice
                    let buffer = [UInt8](data)
                    let length = Int32(data.count)
                    let success = self.device?.sendPacket(data, n: length) ?? false
                    if !success {
                        print("send packet dropped")
                    }
                }
                if let error = error {
                    print("Error reading data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func handleUDPFlow(_ flow: NEAppProxyUDPFlow) {
        let queue = DispatchQueue(label: "UDPFlowQueue")
        queue.async {
            let readBuffer = NSMutableData()
            flow.readDatagrams { datagrams, remoteEndpoints, error in
                if let datagrams = datagrams {
                    for data in datagrams {
                        readBuffer.append(data)
                        // Process the data and send it to BringYourDevice
                        guard let length = Int32(exactly: data.count) else {
                            print("Error: data.count is out of range for Int32")
                            return
                        }
                        let success = self.device?.sendPacket(data, n: length) ?? false
                        if (!success) {
                            print("Send packet dropped.")
                        }
                    }
                }
                if let error = error {
                    print("Error reading datagrams: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func configureNetworkSettings() {
        // TODO: what should we set for the tunnelRemoteAddress value?
        let tunnelNetworkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "")
        
        // Configure IP settings
        let localIpV4Addresses = ["169.254.2.1"] // Equivalent to clientIpv4 in Android Router file
        let localIpV4SubnetMasks = ["255.255.255.0"]
        let ipv4Settings = NEIPv4Settings(addresses: localIpV4Addresses, subnetMasks: localIpV4SubnetMasks)
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        
        // Add custom routes
        let customRoutes: [NEIPv4Route] = [
            NEIPv4Route(destinationAddress: "224.0.0.0", subnetMask: "255.0.0.0"), // Multicast address range
            // Add routes as needed
        ]
        ipv4Settings.includedRoutes?.append(contentsOf: customRoutes)
        
        tunnelNetworkSettings.ipv4Settings = ipv4Settings
        
        // Configure DNS settings
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
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
