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
    
//    private var active = true
    
//    private var tunnel: SdkTunnel?
    
    private var deviceConfiguration: [String: String]?
    private var device: SdkDeviceLocal?
//    private var tunnelDone: DispatchSemaphore?
    
//    private var packetReceiverSub: SdkSubProtocol?
////
//    private var networkSpaceManager: SdkNetworkSpaceManager?
    
    
    
    
    
    override init() {
        super.init()
        logger.info("PacketTunnelProvider init")
    }
    
    deinit {
        self.device?.cancel()
        self.device = nil
    }
    
    
    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping ((any Error)?) -> Void) {
        logger.info("PacketTunnelProvider start")
        
        
        
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
        
        if let device = self.device {
            if self.deviceConfiguration == deviceConfiguration && !device.getDone() {
                // already running
                completionHandler(nil)
                return
            }
        }
        
        
        // create new device with latest config
        
        self.deviceConfiguration = deviceConfiguration
        
//        let networkSpaceManager = SdkNewNetworkSpaceManagerNoStorage()
            let documentsPath = FileManager.default.urls(for: .documentDirectory,
                                                                in: .userDomainMask)[0].path()
            let networkSpaceManager = SdkNewNetworkSpaceManager(documentsPath)
        
        var networkSpace: SdkNetworkSpace?
        do {
            try networkSpace = networkSpaceManager?.importNetworkSpace(fromJson: networkSpaceJson)
        } catch {
            completionHandler(error)
            return
        }
        
        self.device?.cancel()
        
        self.reasserting = true
        
        let instanceId = SdkNewId()
        var err: NSError?
        self.device = SdkNewDeviceLocalWithDefaults(
            networkSpace,
            byJwt,
            "ios-network-extension",
            // FIXME model
            "iPhone",
            // FIXME version
            "0.0.0",
            instanceId,
            true,
            &err
        )
        if let err {
            completionHandler(err)
            return
        }
        
        
        guard let device = self.device else {
            completionHandler(nil)
            return
        }
        
        guard let networkSpace = device.getNetworkSpace() else {
            completionHandler(nil)
            return
        }
        
        guard let localState = networkSpace.getAsyncLocalState()?.getLocalState() else {
            completionHandler(nil)
            return
        }
        
        // load initial device settings
        // these will be in effect until the app connects and sets the user values
        
        // FIXME this needs to be set to true with a connectivity listener
        device.setProvidePaused(true)
        if let location = localState.getConnectLocation() {
            device.setConnectLocation(location)
        }
        device.setProvideMode(localState.getProvideMode())
        device.setRouteLocal(localState.getRouteLocal())
        
        
        let locationChangeSub = device.add(ConnectLocationChangeListener { location in
            try? localState.setConnectLocation(location)
        })
        let provideChangeSub = device.add(ProvideChangeListener { provideEnabled in
            var provideMode: Int
            if provideEnabled {
                provideMode = SdkProvideModePublic
            } else {
                provideMode = SdkProvideModeNone
            }
            try? localState.setProvideMode(provideMode)
        })
        let routeLocalChangeSub = device.add(RouteLocalChangeListener { routeLocal in
            try? localState.setRouteLocal(routeLocal)
        })
        
        
        // FIXME packet receive will need to surface ipv4 or ipv6
        let packetReceiverSub = device.add(PacketReceiver { data in
            self.packetFlow.writePackets([data], withProtocols: [AF_INET as NSNumber])
        })
        
        let close = {
            packetReceiverSub?.close()
            routeLocalChangeSub?.close()
            provideChangeSub?.close()
            locationChangeSub?.close()
            device.close()
        }
        
            
            // Configure network settings
            // FIXME why remote address? can we remove this?
            //   FIXME the remote address IS needed else error
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")//networkSpace.getHostName())//"127.0.0.1")
            //        let networkSettings = NEPacketTunnelNetworkSettings()
            
        
        
        // IPv4 Configuration
        let ipv4Settings = NEIPv4Settings(addresses: ["169.254.2.1"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        
        
        
        networkSettings.ipv4Settings = ipv4Settings
        
        let ipv6Settings = NEIPv6Settings()
        networkSettings.ipv6Settings = ipv6Settings
        
        // DNS Settings
        let dnsSettings = NEDNSSettings(servers: ["1.1.1.1", "8.8.8.8"])
//        dnsSettings.dnsProtocol = NEDNSProtocol.HTTPS
        
//        dnsSettings.matchDomains = [""] // Match all domains
        networkSettings.dnsSettings = dnsSettings
        
        networkSettings.mtu = 1440
//        networkSettings.tunnelOverheadBytes = 0
        
        
        
        // see https://forums.developer.apple.com/forums/thread/661560
        // Apply settings and start packet flow
        setTunnelNetworkSettings(networkSettings) { error in
            if let error = error {
                self.logger.error("Failed to set tunnel network settings: \(error.localizedDescription)")
                close()
                completionHandler(error)
                return
            }
            
            self.logger.info("Network settings applied successfully")
            //            self?.startPacketForwarding()
            //            completionHandler(nil)
            
            
            
            
            Task {
                while !device.getDone() {
                    // see https://developer.apple.com/documentation/networkextension/nepackettunnelflow/readpackets(completionhandler:)
                    // "Each call to this method results in a single execution of the completion handler"
                    // FIXME why is await not needed here?
                    /* await */ self.packetFlow.readPackets { packets, protocols in
                        for packet in packets {
                            device.sendPacket(packet, n: Int32(packet.count))
                        }
                    }
                }
                close()
            }
            
            
            self.reasserting = false
//            tunnelDone.wait()
//            self.reasserting = true
//            
//            readTask.cancel()
//            tunnelCompletionHandler(nil)
            completionHandler(nil)
            
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
        self.device?.cancel()
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
        
        if let packet {
            c(packet)
        }
        
    }
    
    private let c: (Data) -> Void
    
    init(c: @escaping (Data) -> Void) {
        self.c = c
    }
    
}


private class ConnectLocationChangeListener: NSObject, SdkConnectLocationChangeListenerProtocol {
    
    private let c: (_ location: SdkConnectLocation?) -> Void

    init(c: @escaping (_ location: SdkConnectLocation?) -> Void) {
        self.c = c
    }
    
    func connectLocationChanged(_ location: SdkConnectLocation?) {
        c(location)
    }
}


private class ProvideChangeListener: NSObject, SdkProvideChangeListenerProtocol {
    
    private let c: (_ provideEnabled: Bool) -> Void

    init(c: @escaping (_ provideEnabled: Bool) -> Void) {
        self.c = c
    }
    
    func provideChanged(_ provideEnabled: Bool) {
        c(provideEnabled)
    }
}

private class RouteLocalChangeListener: NSObject, SdkRouteLocalChangeListenerProtocol {
    
    private let c: (_ routeLocal: Bool) -> Void

    init(c: @escaping (_ routeLocal: Bool) -> Void) {
        self.c = c
    }
    
    func routeLocalChanged(_ routeLocal: Bool) {
        c(routeLocal)
    }
}

