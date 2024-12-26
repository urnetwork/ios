//
//  PacketTunnelProvider.swift
//  network
//
//  Created by Stuart Kuentzel on 2024/12/24.
//

import NetworkExtension
import URnetworkSdk
import OSLog

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    /**
     * Print does not work for logging with extensions in XCode.
     * You can open up the console app on Mac and filter by subsystem
     */
    private let logger = Logger(
        subsystem: "com.bringyour.network.extension",
        category: "PacketTunnel"
    )
    private var active = true
    
    override init() {
        super.init()
        logger.debug("PacketTunnelProvider init")
    }
    
    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping ((any Error)?) -> Void) {
        
        let packetReceiver = PacketReceiver { [weak self] data in
            guard let self = self, self.active else {
                return
            }
            self.packetFlow.writePackets([data], withProtocols: [AF_INET as NSNumber])
        }
        
        // TODO: add PacketReceiver as a listener to device
        
        
        // Configure network settings
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "65.49.70.71")
        
        // IPv4 Configuration
        let ipv4Settings = NEIPv4Settings(addresses: ["169.254.2.1"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        
        // Add custom routes for handling all traffic
        let customRoutes: [NEIPv4Route] = [
            NEIPv4Route(destinationAddress: "224.0.0.0", subnetMask: "240.0.0.0"),
            NEIPv4Route(destinationAddress: "0.0.0.0", subnetMask: "128.0.0.0"),
            NEIPv4Route(destinationAddress: "128.0.0.0", subnetMask: "128.0.0.0")
        ]
        ipv4Settings.includedRoutes?.append(contentsOf: customRoutes)
        
        networkSettings.ipv4Settings = ipv4Settings
        
        // DNS Settings
        let dnsSettings = NEDNSSettings(servers: ["1.1.1.1", "8.8.8.8"])
        dnsSettings.matchDomains = [""] // Match all domains
        networkSettings.dnsSettings = dnsSettings
        
        // Apply settings and start packet flow
        setTunnelNetworkSettings(networkSettings) { [weak self] error in
            if let error = error {
                self?.logger.debug("Failed to set tunnel network settings: \(error.localizedDescription)")
                completionHandler(error)
                return
            }
            
            self?.logger.debug("Network settings applied successfully")
            self?.startPacketForwarding()
            completionHandler(nil)
        }
    }
    
    private func startPacketForwarding() {
        logger.debug("Starting packet forwarding")
        readPackets()
    }
    
    private func readPackets() {
        guard active else {
            logger.debug("Packet forwarding inactive")
            return
        }
        
        packetFlow.readPackets { [weak self] packets, protocols in
            guard let self = self, self.active else { return }
            
            for (index, packet) in packets.enumerated() {
                guard let length = Int32(exactly: packet.count) else {
                    logger.debug("Packet size error: \(packet.count)")
                    continue
                }
                
                // TODO: device send packet
                
            }
            
            
            // Is this necessary?
            // self.readPackets()
        }
    }
    
//    private func setupPacketReceiving() {
//
//        packetReceiver = PacketReceiver { [weak self] data in
//            self?.packetFlow.writePackets([data], withProtocols: [AF_INET as NSNumber])
//        }
//
//        // Handle incoming packets from BringYourDevice
//        device?.add(packetReceiver)
//    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        self.logger.debug("Stopping tunnel with reason: \(String(describing: reason))")
        active = false
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
}


private class PacketReceiver: NSObject, SdkReceivePacketProtocol {
    func receivePacket(_ packet: Data?) {
        
        guard let packet = packet else {
            print("packet is nil")
            return
        }
        
        onReceiveCallback(packet)
        
        // provider?.packetFlow.writePackets([packet], withProtocols: [AF_INET as NSNumber])
    }
    
    private let onReceiveCallback: (Data) -> Void
    
    init(onReceive: @escaping (Data) -> Void) {
        self.onReceiveCallback = onReceive
    }
    
}
