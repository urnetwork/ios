//
//  PacketTunnelProvider.swift
//  network
//
//  Created by Stuart Kuentzel on 2024/12/24.
//

import NetworkExtension
import URnetworkSdk
import OSLog

// see https://developer.apple.com/documentation/networkextension/nepackettunnelprovider
// discussion on how the PacketTunnelProvider is excluded from the routes it sets up:
// see https://forums.developer.apple.com/forums/thread/677180
class PacketTunnelProvider: NEPacketTunnelProvider {
    
    /**
     * Print does not work for logging with extensions in XCode.
     * You can open up the console app on Mac and filter by subsystem
     */
    private let logger = Logger(
        subsystem: "com.bringyour.network.extension",
        category: "PacketTunnel"
        
    )
    
    // FIXME lock
    private var active = true
    
    
    private var deviceConfiguration: [String: String]?
    private var device: SdkDeviceLocal?
    
//    private var packetReceiverSub: SdkSubProtocol?
////
//    private var networkSpaceManager: SdkNetworkSpaceManager?
    
    
    
    
    
    override init() {
        super.init()
        logger.info("PacketTunnelProvider init")
        
        print("INIT TUNNEL")
        
//        let documentsPath = FileManager.default.urls(for: .documentDirectory,
//                                                     in: .userDomainMask)[0].path()
////
////
//        networkSpaceManager = SdkNewNetworkSpaceManager(documentsPath)
        // FIXME use no storage
//        networkSpaceManager = SdkNewNetworkSpaceManagerNoStorage()
    }
    
    
    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping ((any Error)?) -> Void) {
        logger.info("PacketTunnelProvider start")
        print("START TUNNEL")
        
//        device?.close()
//        
//        
//        var err: NSError?
        
        guard let providerConfiguration = (protocolConfiguration as? NETunnelProviderProtocol)?.providerConfiguration else {
            logger.info( "PacketTunnelProvider start failed - no providerConfiguration")
            completionHandler(nil)
            return
        }
        
        
        guard let byJwt = providerConfiguration["by_jwt"] as? String else {
            completionHandler(nil)
            return
        }
        
        guard let networkSpaceJson = providerConfiguration["network_space"] as? String else {
            completionHandler(nil)
            return
        }
        
        guard let rpcPublicKey = providerConfiguration["rpc_public_key"] as? String else {
            completionHandler(nil)
            return
        }
        
        let deviceConfiguration = [
            "by_jwt": byJwt,
            "network_space": networkSpaceJson,
            "rpc_public_key": rpcPublicKey
        ]
        
        if self.deviceConfiguration != deviceConfiguration {
            self.deviceConfiguration = deviceConfiguration
            
            let networkSpaceManager = SdkNewNetworkSpaceManagerNoStorage()
//            let documentsPath = FileManager.default.urls(for: .documentDirectory,
//                                                                in: .userDomainMask)[0].path()
//            let networkSpaceManager = SdkNewNetworkSpaceManager(documentsPath)
            
            var networkSpace: SdkNetworkSpace?
            do {
                try networkSpace = networkSpaceManager?.importNetworkSpace(fromJson: networkSpaceJson)
            } catch {
                completionHandler(error)
                return
            }
            
            device?.close()
            let instanceId = SdkNewId()
            var err: NSError?
            device = SdkNewDeviceLocalWithDefaults(
                networkSpace,
                byJwt,
                "",
                "",
                "",
                instanceId,
                true,
                &err
            )
            if let err {
                completionHandler(err)
                return
            }
        }
        
        
        guard let device = self.device else {
            completionHandler(nil)
            return
        }
        
        guard let networkSpace = device.getNetworkSpace() else {
            completionHandler(nil)
            return
        }
            
            
        self.active = true
            
            // Configure network settings
            // FIXME why remote address? can we remove this?
            //   FIXME the remote address IS needed else error
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: networkSpace.getHostName())//"127.0.0.1")
            //        let networkSettings = NEPacketTunnelNetworkSettings()
            
        
        
        // IPv4 Configuration
        let ipv4Settings = NEIPv4Settings(addresses: ["169.254.2.1"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        
        /*
         // Add custom routes for handling all traffic
         let customRoutes: [NEIPv4Route] = [
         NEIPv4Route(destinationAddress: "224.0.0.0", subnetMask: "240.0.0.0"),
         NEIPv4Route(destinationAddress: "0.0.0.0", subnetMask: "128.0.0.0"),
         NEIPv4Route(destinationAddress: "128.0.0.0", subnetMask: "128.0.0.0")
         ]
         ipv4Settings.includedRoutes?.append(contentsOf: customRoutes)
         */
        // FIXME exclude local routes
        
        // FIXME exclude API and connect routes
        // FIXME turn off p2p for ios?
        
        
        
        networkSettings.ipv4Settings = ipv4Settings
        
        // DNS Settings
        let dnsSettings = NEDNSSettings(servers: ["1.1.1.1", "8.8.8.8"])
        dnsSettings.matchDomains = [""] // Match all domains
        networkSettings.dnsSettings = dnsSettings
        
        
        let packetReceiverSub = device.add(PacketReceiver { data in
            guard self.active else {
                return
            }
            self.packetFlow.writePackets([data], withProtocols: [AF_INET as NSNumber])
        })
        
        
        let handlerDone = { (err: Error?) in
            self.active = false
            packetReceiverSub?.close()
            completionHandler(err)
        }
        
        // Apply settings and start packet flow
        setTunnelNetworkSettings(networkSettings) { error in
            if let error = error {
                self.logger.debug("Failed to set tunnel network settings: \(error.localizedDescription)")
                handlerDone(error)
                return
            }
            
            self.logger.debug("Network settings applied successfully")
            //            self?.startPacketForwarding()
            //            completionHandler(nil)
            
            self.packetFlow.readPackets { packets, protocols in
                
                for (index, packet) in packets.enumerated() {
                    guard self.active else {
                        handlerDone(nil)
                        return
                    }
                    
                    guard let length = Int32(exactly: packet.count) else {
                        self.logger.debug("Packet size error: \(packet.count)")
                        continue
                    }
                    
                    device.sendPacket(packet, n: length)
                    
                }
                
                handlerDone(nil)
            }
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
        self.logger.info("Stopping tunnel with reason: \(String(describing: reason))")
        print("STOP TUNNEL")
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
        
        c(packet)
        
        // provider?.packetFlow.writePackets([packet], withProtocols: [AF_INET as NSNumber])
    }
    
    private let c: (Data) -> Void
    
    init(c: @escaping (Data) -> Void) {
        self.c = c
    }
    
}
