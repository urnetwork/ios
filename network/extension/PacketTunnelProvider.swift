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
    
    private let logger = Logger(
        subsystem: "com.bringyour.network.extension",
        category: "PacketTunnel"
        // privacy: .public
    )
    // private var device: SdkBringYourDevice?
    private var active = true
    // private var packetReceiver: PacketReceiver?
    private var packetHandler: SdkPacketHandler?
    // private var sendPacketCallback: (Data, Int32) -> Void
    private static var initCount = 0
    
    override init() {
        super.init()
        PacketTunnelProvider.initCount += 1
        logger.info("PacketTunnelProvider initialized (count: \(PacketTunnelProvider.initCount))")
    }
    
    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping ((any Error)?) -> Void) {
        // logger.debug("Raw options received: \(String(describing: options))")
        // logger.debug("StartTunnel called", privacy: .public)
        
        logger.debug("Options present: \(options != nil)")
        logger.debug("Options count: \(options?.count ?? 0)")
        
        
        
        let optionsDescription = options?.mapValues { "\(type(of: $0))" } ?? [:]
        logger.debug("Raw options received: \(optionsDescription, privacy: .public)")
        
        
        // Verify tunnelManager configuration
        if let configuration = protocolConfiguration as? NETunnelProviderProtocol {
            logger.debug("Tunnel configuration: \(configuration)")
            logger.debug("Provider bundle ID: \(String(describing: configuration.providerBundleIdentifier))")
            
        } else {
            logger.error("Failed to get tunnel configuration")
        }
        
        // 1. Initialize device
//        guard let options = options,
//              let device = options["device"] as? SdkBringYourDevice else {
//            logger.error("Failed to initialize device from options")
//            completionHandler(NSError(domain: NEVPNErrorDomain, code: 1, userInfo: nil))
//            return
//        }
        
//        guard let options = options,
//                let packetHandler = options["sendPacket"] as? SdkPacketHandler,
//                let packetReceiverCallback = options["receivePacket"] as? SdkReceivePacket else {
//            logger.error("Failed to get packet handler or ")
//            completionHandler(NSError(domain: NEVPNErrorDomain, code: 1, userInfo: nil))
//            return
//        }
        
        logger.debug("Starting tunnel with options: \(String(describing: options))")
        
        // Inspect all options
        if let options = options {
            logger.debug("Options keys: \(options.keys)")
            options.forEach { key, value in
                logger.debug("Key: \(key)")
                logger.debug("Value type: \(type(of: value))")
                logger.debug("Value description: \(value)")
            }
        } else {
            logger.debug("no options found")
        }
        
        
        if let packetHandlerObj = options?["packetHandler"] {
            logger.debug("PacketHandler type: \(type(of: packetHandlerObj))")
            logger.debug("Can cast to SdkPacketHandler: \(packetHandlerObj is SdkPacketHandler)")
        } else {
            logger.debug("no packetHandler found in options")
        }
        
        guard let options = options,
                let packetHandler = options["packetHandler"] as? SdkPacketHandler else {
            logger.error("Failed to parse packet handler")
            completionHandler(NSError(domain: NEVPNErrorDomain, code: 1, userInfo: nil))
            return
        }
        
        
        self.packetHandler = packetHandler
        
        logger.info("222 Starting tunnel")
        
        // self.device = device
        logger.info("Device configured successfully")
        
        // 2. Initialize packet receiver
        let packetReceiver = PacketReceiver { [weak self] data in
            guard let self = self, self.active else {
                print("Packet receiver inactive or self deallocated")
                return
            }
            NSLog("Writing packet of size: \(data.count)")
            self.packetFlow.writePackets([data], withProtocols: [AF_INET as NSNumber])
        }
        
        packetHandler.setupPacketReceiver(packetReceiver)
        
        NSLog("333 Starting tunnel")
        
        // device.add(packetReceiver)
        NSLog("Packet receiver configured")
        
        // 3. Configure network settings
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
        
        NSLog("Applying network settings...")
        
        // 4. Apply settings and start packet flow
        setTunnelNetworkSettings(networkSettings) { [weak self] error in
            if let error = error {
                print("Failed to set tunnel network settings: \(error.localizedDescription)")
                completionHandler(error)
                return
            }
            
            NSLog("Network settings applied successfully")
            self?.startPacketForwarding()
            completionHandler(nil)
        }
    }
    
    private func startPacketForwarding() {
        NSLog("Starting packet forwarding")
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
                
                self.packetHandler?.sendPacket(packet)
                
//                let success = self.device?.sendPacket(packet, n: length) ?? false
//                if !success {
//                    print("Failed to send packet of size: \(length)")
//                }
            }
            
            
            // Do I need this still if callback is passing packets to device?
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
    
}
