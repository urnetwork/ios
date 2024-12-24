//
//  AppProxyProvider.swift
//  extension
//
//  Created by brien on 11/18/24.
//

import NetworkExtension
import URnetworkSdk

class AppProxyProvider: NEAppProxyProvider {
    
//    var device: SdkBringYourDevice?
//    var active = true
//
//    override func startProxy(options: [String : Any]? = nil, completionHandler: @escaping (Error?) -> Void) {
//        // Add code here to start the process of connecting the tunnel.
//        
//        if let options = options, let device = options["device"] as? SdkBringYourDevice {
//            self.device = device
//        }
//        
//        configureNetworkSettings()
//        completionHandler(nil)
//    }
//    
//    override func stopProxy(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
//        // Add code here to start the process of stopping the tunnel.
//        
//        active = false
//        
//        completionHandler()
//    }
//    
//    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
//        // Add code here to handle the message.
//        if let handler = completionHandler {
//            handler(messageData)
//        }
//    }
//    
//    override func sleep(completionHandler: @escaping() -> Void) {
//        // Add code here to get ready to sleep.
//        completionHandler()
//    }
//    
//    override func wake() {
//        // Add code here to wake up.
//    }
//    
//    override func handleNewFlow(_ flow: NEAppProxyFlow) -> Bool {
//        // Add code here to handle the incoming flow.
//        
//        guard active else { return false }
//        
//        if let tcpFlow = flow as? NEAppProxyTCPFlow {
//            handleTCPFlow(tcpFlow)
//            return true
//        } else if let udpFlow = flow as? NEAppProxyUDPFlow {
//            handleUDPFlow(udpFlow)
//            return true
//        }
//        
//        return false
//    }
//    
//    private func handleTCPFlow(_ flow: NEAppProxyTCPFlow) {
//        let queue = DispatchQueue(label: "TCPFlowQueue")
//        queue.async {
//            let readBuffer = NSMutableData()
//            flow.readData { data, error in
//                if let data = data {
//                    readBuffer.append(data)
//                    // Process the data and send it to BringYourDevice
//                    let buffer = [UInt8](data)
//                    let length = Int32(data.count)
//                    let success = self.device?.sendPacket(data, n: length) ?? false
//                    if !success {
//                        print("send packet dropped")
//                    }
//                }
//                if let error = error {
//                    print("Error reading data: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    
//    private func handleUDPFlow(_ flow: NEAppProxyUDPFlow) {
//        let queue = DispatchQueue(label: "UDPFlowQueue")
//        queue.async {
//            let readBuffer = NSMutableData()
//            flow.readDatagrams { datagrams, remoteEndpoints, error in
//                if let datagrams = datagrams {
//                    for data in datagrams {
//                        readBuffer.append(data)
//                        // Process the data and send it to BringYourDevice
//                        guard let length = Int32(exactly: data.count) else {
//                            print("Error: data.count is out of range for Int32")
//                            return
//                        }
//                        let success = self.device?.sendPacket(data, n: length) ?? false
//                        if (!success) {
//                            print("Send packet dropped.")
//                        }
//                    }
//                }
//                if let error = error {
//                    print("Error reading datagrams: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    
//    private func configureNetworkSettings() {
//        // TODO: what should we set for the tunnelRemoteAddress value?
//        let tunnelNetworkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
//        
//        // Configure IP settings
//        // let localIpV4Addresses = ["169.254.2.1"] // Equivalent to clientIpv4 in Android Router file
//        let localIpV4Addresses = ["192.168.3.4"]
//        let localIpV4SubnetMasks = ["255.255.255.0"]
//        let ipv4Settings = NEIPv4Settings(addresses: localIpV4Addresses, subnetMasks: localIpV4SubnetMasks)
//        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
//        
//        // Add custom routes
//        let customRoutes: [NEIPv4Route] = [
//            NEIPv4Route(destinationAddress: "224.0.0.0", subnetMask: "255.0.0.0"), // Multicast address range
//            NEIPv4Route(destinationAddress: "208.0.0.0", subnetMask: "240.0.0.0"),
//            NEIPv4Route(destinationAddress: "200.0.0.0", subnetMask: "248.0.0.0"),
//            NEIPv4Route(destinationAddress: "196.0.0.0", subnetMask: "252.0.0.0"),
//            NEIPv4Route(destinationAddress: "194.0.0.0", subnetMask: "254.0.0.0"),
//            NEIPv4Route(destinationAddress: "193.0.0.0", subnetMask: "255.0.0.0"),
//            NEIPv4Route(destinationAddress: "192.0.0.0", subnetMask: "255.128.0.0"),
//            NEIPv4Route(destinationAddress: "192.192.0.0", subnetMask: "255.192.0.0"),
//            NEIPv4Route(destinationAddress: "192.128.0.0", subnetMask: "255.224.0.0"),
//            NEIPv4Route(destinationAddress: "192.176.0.0", subnetMask: "255.240.0.0"),
//            NEIPv4Route(destinationAddress: "192.160.0.0", subnetMask: "255.248.0.0"),
//            NEIPv4Route(destinationAddress: "192.172.0.0", subnetMask: "255.254.0.0"),
//            NEIPv4Route(destinationAddress: "192.170.0.0", subnetMask: "255.255.0.0"),
//            NEIPv4Route(destinationAddress: "192.169.0.0", subnetMask: "255.255.0.0"),
//            NEIPv4Route(destinationAddress: "128.0.0.0", subnetMask: "255.128.0.0"),
//            NEIPv4Route(destinationAddress: "176.0.0.0", subnetMask: "255.240.0.0"),
//            NEIPv4Route(destinationAddress: "160.0.0.0", subnetMask: "255.248.0.0"),
//            NEIPv4Route(destinationAddress: "168.0.0.0", subnetMask: "255.252.0.0"),
//            NEIPv4Route(destinationAddress: "174.0.0.0", subnetMask: "255.254.0.0"),
//            NEIPv4Route(destinationAddress: "173.0.0.0", subnetMask: "255.255.0.0"),
//            NEIPv4Route(destinationAddress: "172.128.0.0", subnetMask: "255.192.0.0"),
//            NEIPv4Route(destinationAddress: "172.64.0.0", subnetMask: "255.192.0.0"),
//            NEIPv4Route(destinationAddress: "172.32.0.0", subnetMask: "255.224.0.0"),
//            NEIPv4Route(destinationAddress: "172.0.0.0", subnetMask: "255.240.0.0"),
//            NEIPv4Route(destinationAddress: "64.0.0.0", subnetMask: "255.192.0.0"),
//            NEIPv4Route(destinationAddress: "32.0.0.0", subnetMask: "255.224.0.0"),
//            NEIPv4Route(destinationAddress: "16.0.0.0", subnetMask: "255.240.0.0"),
//            NEIPv4Route(destinationAddress: "0.0.0.0", subnetMask: "255.240.0.0"),
//            NEIPv4Route(destinationAddress: "12.0.0.0", subnetMask: "255.248.0.0"),
//            NEIPv4Route(destinationAddress: "8.0.0.0", subnetMask: "255.254.0.0"),
//            NEIPv4Route(destinationAddress: "11.0.0.0", subnetMask: "255.255.0.0")
//            
//        ]
//        ipv4Settings.includedRoutes?.append(contentsOf: customRoutes)
//        
//        // Exclude specific routes
//        let excludedRoutes: [NEIPv4Route] = [
//            NEIPv4Route(destinationAddress: "10.0.0.0", subnetMask: "255.0.0.0"),
//            NEIPv4Route(destinationAddress: "172.16.0.0", subnetMask: "255.240.0.0"),
//            NEIPv4Route(destinationAddress: "192.168.0.0", subnetMask: "255.255.0.0")
//        ]
//        ipv4Settings.excludedRoutes = excludedRoutes
//        
//        tunnelNetworkSettings.ipv4Settings = ipv4Settings
//        
//        // Configure DNS settings
//        let dnsSettings = NEDNSSettings(servers: ["1.1.1.1", "8.8.8.8", "8.8.4.4", "9.9.9.9"])
//        tunnelNetworkSettings.dnsSettings = dnsSettings
//        
//        // Apply the network settings
//        setTunnelNetworkSettings(tunnelNetworkSettings) { error in
//            if let error = error {
//                print("Error setting tunnel network settings: \(error.localizedDescription)")
//            } else {
//                print("Tunnel network settings applied successfully")
//            }
//        }
//    }
}
