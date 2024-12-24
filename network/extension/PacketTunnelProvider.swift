//
//  PacketTunnelProvider.swift
//  network
//
//  Created by Stuart Kuentzel on 2024/12/24.
//

import NetworkExtension
import URnetworkSdk

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    private var device: SdkBringYourDevice?
    private var active = true
    private var packetReceiver: PacketReceiver?
    
    override init() {
        print("QNEPacketTunnel.Provider: init")
        super.init()
    }
    
    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping ((any Error)?) -> Void) {
        print("111111111 Starting tunnel")
        
        // 1. Initialize device
        guard let options = options,
              let device = options["device"] as? SdkBringYourDevice else {
            print("Failed to initialize device from options")
            completionHandler(NSError(domain: NEVPNErrorDomain, code: 1, userInfo: nil))
            return
        }
        
        self.device = device
        print("Device configured successfully")
        
        // 2. Initialize packet receiver
        packetReceiver = PacketReceiver { [weak self] data in
            guard let self = self, self.active else {
                print("Packet receiver inactive or self deallocated")
                return
            }
            print("Writing packet of size: \(data.count)")
            self.packetFlow.writePackets([data], withProtocols: [AF_INET as NSNumber])
        }
        
        device.add(packetReceiver)
        print("Packet receiver configured")
        
        // 3. Configure network settings
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        
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
        
        print("Applying network settings...")
        
        // 4. Apply settings and start packet flow
        setTunnelNetworkSettings(networkSettings) { [weak self] error in
            if let error = error {
                print("Failed to set tunnel network settings: \(error.localizedDescription)")
                completionHandler(error)
                return
            }
            
            print("Network settings applied successfully")
            self?.startPacketForwarding()
            completionHandler(nil)
        }
    }
    
    private func startPacketForwarding() {
        print("Starting packet forwarding")
        readPackets()
    }
    
    private func readPackets() {
        guard active else {
            print("Packet forwarding inactive")
            return
        }
        
        packetFlow.readPackets { [weak self] packets, protocols in
            guard let self = self, self.active else { return }
            
            for (index, packet) in packets.enumerated() {
                guard let length = Int32(exactly: packet.count) else {
                    print("Packet size error: \(packet.count)")
                    continue
                }
                
                let success = self.device?.sendPacket(packet, n: length) ?? false
                if !success {
                    print("Failed to send packet of size: \(length)")
                }
            }
            
            self.readPackets()
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
//    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        print("Stopping tunnel with reason: \(reason)")
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
    
//    func onReceive(data: Data) {
//        provider?.packetFlow.writePackets([data], withProtocols: [AF_INET as NSNumber])
//    }
}
