//
//  VPNManager.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/20.
//

import Foundation
import NetworkExtension
import URnetworkSdk

//@objc protocol SendPacketCallback: NSObjectProtocol {
//    func sendPacket(_ packet: Data, length: Int32)
//}
//
//class SendPacketCallbackImpl: NSObject, SendPacketCallback {
//    private let callback: (Data, Int32) -> Void
//    
//    init(callback: @escaping (Data, Int32) -> Void) {
//        self.callback = callback
//        super.init()
//    }
//    
//    func sendPacket(_ packet: Data, length: Int32) {
//        callback(packet, length)
//    }
//}


class PacketHandler: NSObject, SdkPacketHandlerProtocol {
    
    private let sendPacketCallback: (Data, Int32) -> Void
    private let setupPacketReceiverCallback: ((any SdkReceivePacketProtocol)?) -> Void
    
    init(
        sendPacketCallback: @escaping (Data, Int32) -> Void,
        setupPacketReceiverCallback: @escaping ((any SdkReceivePacketProtocol)?) -> Void
    ) {
        self.sendPacketCallback = sendPacketCallback
        self.setupPacketReceiverCallback = setupPacketReceiverCallback
        super.init()
    }
    
    func sendPacket(_ packet: Data?) -> Void {
        guard let packet = packet else {
            print("packet is nil")
            return
        }

        sendPacketCallback(packet, Int32(packet.count))
    }
    
    func setupPacketReceiver(_ receiver: (any SdkReceivePacketProtocol)?) {
        setupPacketReceiverCallback(receiver)
    }
}

//class PacketReceiverCallbackImpl: NSObject {
//    
//    private let callback: (SdkReceivePacket) -> Void
//    
//    init(callback: @escaping (SdkReceivePacket) -> Void) {
//        self.callback = callback
//        super.init()
//    }
//    
////    func receivePacket(_ packet: Data?) {
////        callback(packet)
////    }
//    
//    
//}


//class SendPacketCallbackImpl: NSObject, TunnelCallback {
//    private weak var vpnManager: VPNManager?
//    
//    init(vpnManager: VPNManager) {
//        self.vpnManager = vpnManager
//    }
//    
//    func getDevice() -> SdkBringYourDevice {
//        return vpnManager?.device ?? SdkBringYourDevice()
//    }
//    
//    func handleTunnelEvent(_ event: String) {
//        // Handle tunnel events
//    }
//}

class VPNManager {
    
    var device: SdkBringYourDevice
    var tunnelManager: NETunnelProviderManager?
    
    init(device: SdkBringYourDevice) {
        print("VPN Manager init hit")
        self.device = device
        // self.tunnelManager = NETunnelProviderManager()
        // self.setup()
        self.loadOrCreateManager()
    }
    
    private func loadOrCreateManager() {
        // Load all configurations first
        NETunnelProviderManager.loadAllFromPreferences { [weak self] (managers, error) in
            if let error = error {
                print("Error loading managers: \(error.localizedDescription)")
                return
            }
            
            print("NETunnelProviderManager.loadAllFromPreferences")
            
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
        
        if let tunnelManager = tunnelManager {
            print("Tunnel Status: \(tunnelManager.connection.status)")
            print("Connection is active: \(tunnelManager.isEnabled)")
        }
        
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
//        var options: [String: NSObject] = [:]
//        options["device"] = device
        
//        let options: [String: NSObject] = [
//            "device": device
//        ]
        
//        let sendPacketCallback = PacketHandler { [weak self] packet, length in
//            // self?.device.send(packet)
//            guard let self = self else {
//                print("no self in SendPacketCallbackImpl")
//                return
//            }
//            
//            self.device.sendPacket(packet, n: length)
//        }
        
        let sendPacketCallback: (Data, Int32) -> Void = { [weak self] packet, length in
            // self?.device.send(packet)
            guard let self = self else {
                print("no self in SendPacketCallbackImpl")
                return
            }

            self.device.sendPacket(packet, n: length)
        }
        
        let setupPacketReceiverCallback: ((any SdkReceivePacketProtocol)?) -> Void = { [weak self] packetReceiver in
            guard let self = self else {
                print("no self in PacketReceiverCallbackImpl")
                return
            }
            
            device.add(packetReceiver)
        }
        
        let packetHandler = PacketHandler(
            sendPacketCallback: sendPacketCallback,
            setupPacketReceiverCallback: setupPacketReceiverCallback
        )
        
        print("PacketHandler type: \(type(of: packetHandler))")
        print("PacketHandler class: \(String(describing: packetHandler.self))")
        print("Available methods: \(Mirror(reflecting: packetHandler).children.map { $0.label ?? "" })")
        
        if let asNSObject = packetHandler as? NSObject {
            print("Class hierarchy: \(type(of: asNSObject))")
            print("Responds to sendPacket: \(asNSObject.responds(to: #selector(SdkPacketHandlerProtocol.sendPacket(_:))))")
        }
        
        print("PacketHandler: \(packetHandler)")
        print("Is NSObject?: \(packetHandler is NSObject)")
        
//        let receivePacketCallback = PacketReceiverCallbackImpl { [weak self] packetReceiver in
//            
//            guard let self = self else {
//                print("no self in PacketReceiverCallbackImpl")
//                return
//            }
//            
//            device.add(packetReceiver)
//        }
        
        let options: [String: NSObject] = [
            "packetHandler": packetHandler
        ]
        
        print("Options before tunnel start: \(options)")
        print("Debug - Options Dictionary:")
        print("Count: \(options.count)")
        print("Keys: \(options.keys)")
        print("Values: \(options.values.map { type(of: $0) })")
        
        
        do {
            
            try self.tunnelManager?.connection.startVPNTunnel(
                options: options
            )
            
            print("VPN connection started")
            
            if let tunnelManager = tunnelManager {
                print("Tunnel Status: \(tunnelManager.connection.status)")
                print("Connection is active: \(tunnelManager.isEnabled)")
                
            }
            
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
