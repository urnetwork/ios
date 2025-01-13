//
//  VPNManager.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/20.
//

import Foundation
import UIKit
import NetworkExtension
import URnetworkSdk

enum TunnelRequestStatus {
    case started
    case stopped
    case none
}

class VPNManager {
    
    var device: SdkDeviceRemote
//    var tunnelManager: NETunnelProviderManager?
    
    var tunnelRequestStatus: TunnelRequestStatus = .none
    
    var routeLocalSub: SdkSubProtocol?
    
    var deviceProvideSub: SdkSubProtocol?
    
    var deviceProvidePausedSub: SdkSubProtocol?
    
    var deviceOflineSub: SdkSubProtocol?
    
    var deviceConnectSub: SdkSubProtocol?
    
    var deviceRemoteSub: SdkSubProtocol?
    
    
    init(device: SdkDeviceRemote) {
        print("VPN Manager init")
        self.device = device
//        self.loadOrCreateManager()
        
        self.routeLocalSub = device.add(RouteLocalChangeListener { [weak self] routeLocal in
            mainImmediateBlocking {
                self?.updateVpnService()
            }
        })
        
        self.deviceProvideSub = device.add(ProvideChangeListener { [weak self] provideEnabled in
            mainImmediateBlocking {
                self?.updateVpnService()
            }
        })
        
        self.deviceProvidePausedSub = device.add(ProvidePausedChangeListener { [weak self] providePaused in
            mainImmediateBlocking {
                self?.updateVpnService()
            }
        })
        
        self.deviceOflineSub = device.add(OfflineChangeListener { [weak self] offline, vpnInterfaceWhileOffline in
            mainImmediateBlocking {
                self?.updateVpnService()
            }
        })
        
        self.deviceConnectSub = device.add(ConnectChangeListener { [weak self] connectEnabled in
            mainImmediateBlocking {
                self?.updateVpnService()
            }
        })
        
        
        self.deviceRemoteSub = device.add(RemoteChangeListener { [weak self] remoteConnected in
            guard let self = self else {
                return
            }
            
            mainImmediateBlocking {
                if !remoteConnected {
                    // recheck the last known state to make sure remote is not supposed to be active
                    self.updateVpnService()
                }
            }
        })
        
        updateVpnService()
    }
    
    deinit {
        print("VPN Manager deinit")
        
        self.routeLocalSub?.close()
        self.routeLocalSub = nil
        
        self.deviceProvideSub?.close()
        self.deviceProvideSub = nil
        
        self.deviceProvidePausedSub?.close()
        self.deviceProvidePausedSub = nil
        
        self.deviceOflineSub?.close()
        self.deviceOflineSub = nil
        
        self.deviceConnectSub?.close()
        self.deviceConnectSub = nil
    }
    
 
    
    private func getPasswordReference() -> Data? {
        // Retrieve the password reference from the keychain
        return nil
    }
    
    
    
    private func updateVpnService() {
        
        let provideEnabled = device.getProvideEnabled()
        let providePaused = device.getProvidePaused()
        let connectEnabled = device.getConnectEnabled()
        let routeLocal = device.getRouteLocal()
        
        if (provideEnabled || connectEnabled || !routeLocal) {
            print("start vpn")
            
            // see https://developer.apple.com/documentation/uikit/uiapplication/isidletimerdisabled
            UIApplication.shared.isIdleTimerDisabled = true
            
            self.start()
            
            
        } else {
            
            print("stop vpn")
            self.stop()
            
            UIApplication.shared.isIdleTimerDisabled = false
            
        }
        
        
    }
    
    
    
    
    private func start() {
        
//        if let tunnelManager = self.tunnelManager {
//            let status = tunnelManager.connection.status
//            switch status {
//            case .connected, .connecting:
//                return
//            default:
//                break
//            }
//        }
        if self.tunnelRequestStatus == .started {
            return
        }
        
        // Load all configurations first
        NETunnelProviderManager.loadAllFromPreferences { [weak self] (managers, error) in
            if let error = error {
                print("Error loading managers: \(error.localizedDescription)")
                return
            }
            guard let self = self else {
                return
            }
            
            // Use existing manager or create new one
            let tunnelManager = managers?.first ?? NETunnelProviderManager()
//            self.tunnelManager = tunnelManager
            
            guard let networkSpace = self.device.getNetworkSpace() else {
                return
            }
            
            
            
            // FIXME provider configuration:
            // 1. byJwt
            // 2. rpc public cert
            // 3. network space
            var err: NSError?
            let networkSpaceJson = networkSpace.toJson(&err)
            if let err {
                print("Error converting network space to json: \(err.localizedDescription)")
                return
            }
            
            let tunnelProtocol = NETunnelProviderProtocol()
            // Use the same as remote address in PacketTunnelProvider
            // value from connect resolvedHost
            tunnelProtocol.serverAddress = networkSpace.getHostName()//"127.0.0.1"
            tunnelProtocol.providerBundleIdentifier = "com.bringyour.network.extension"
            tunnelProtocol.disconnectOnSleep = false
            // see https://developer.apple.com/documentation/networkextension/nevpnprotocol/includeallnetworks
            tunnelProtocol.includeAllNetworks = true
            // this is needed for casting, etc.
            tunnelProtocol.excludeLocalNetworks = true
            if #available(iOS 17.4, *) {
                tunnelProtocol.excludeDeviceCommunication = true
            }
            
            tunnelProtocol.enforceRoutes = true
            
            tunnelProtocol.providerConfiguration = [
                "by_jwt": self.device.getApi()?.getByJwt() as Any,
                "rpc_public_key": "test",
                "network_space": networkSpaceJson as Any,
                "instance_id": self.device.getInstanceId()?.string() as Any,
            ]
            
            
            tunnelManager.protocolConfiguration = tunnelProtocol
            tunnelManager.localizedDescription = "URnetwork [\(networkSpace.getHostName()) \(networkSpace.getEnvName())]"
            tunnelManager.isEnabled = true
            tunnelManager.isOnDemandEnabled = true
            let connectRule = NEOnDemandRuleConnect()
            connectRule.interfaceTypeMatch = NEOnDemandRuleInterfaceType.any
            tunnelManager.onDemandRules = [connectRule]
            
            tunnelManager.saveToPreferences { [weak self] error in
                if let error = error {
                    // when changing locations quickly, another change might have intercepted this save
//                    print("Error saving preferences: \(error.localizedDescription)")
                    return
                }
                print("VPN configuration saved successfully")
                
                // see https://forums.developer.apple.com/forums/thread/25928
                tunnelManager.loadFromPreferences { [weak self] error in
                    
                    self?.connect(tunnelManager: tunnelManager)
                }
                
                
                
                
            }
        }
    }	
    
    private func stop() {
        if self.tunnelRequestStatus == .stopped {
            return
        }
        
        
//        guard let tunnelManager = self.tunnelManager else {
//            return
//        }
//        
//        let status = tunnelManager.connection.status
//        switch status {
//        case .disconnected, .disconnecting:
//            return
//        default:
//            break
//        }
        
        
        NETunnelProviderManager.loadAllFromPreferences { [weak self] (managers, error) in
            if let error = error {
                print("Error loading managers: \(error.localizedDescription)")
                return
            }
            guard let self = self else {
                return
            }
            
            // Use existing manager or create new one
            guard let tunnelManager = managers?.first else {
                return
            }
            
            
            tunnelManager.isEnabled = false
            tunnelManager.isOnDemandEnabled = false
            
            tunnelManager.saveToPreferences { [weak self] error in
                if let error = error {
                    // when changing locations quickly, another change might have intercepted this save
                    return
                }
                
                // see https://forums.developer.apple.com/forums/thread/25928
                tunnelManager.loadFromPreferences { [weak self] error in
                    
                    self?.disconnect(tunnelManager: tunnelManager)
                }
                
                
                
                
            }
        }
    }
    
    func connect(tunnelManager: NETunnelProviderManager) {
        if self.tunnelRequestStatus == .started {
            return
        }
        self.tunnelRequestStatus = .started
        
        do {
            
            try tunnelManager.connection.startVPNTunnel()
            print("VPN connection started")
            
            self.device.sync()
            
        } catch let error as NSError {
            
            print("Error starting VPN connection:")
            print("Domain: \(error.domain)")
            print("Code: \(error.code)")
            print("Description: \(error.localizedDescription)")
            print("User Info: \(error.userInfo)")
            
        }
    }
    
    func disconnect(tunnelManager: NETunnelProviderManager) {
        if self.tunnelRequestStatus == .stopped {
            return
        }
        self.tunnelRequestStatus = .stopped
        
        tunnelManager.connection.stopVPNTunnel()
        print("VPN connection stopped")
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

private class ProvideChangeListener: NSObject, SdkProvideChangeListenerProtocol {
    
    private let c: (_ provideEnabled: Bool) -> Void

    init(c: @escaping (_ provideEnabled: Bool) -> Void) {
        self.c = c
    }
    
    func provideChanged(_ provideEnabled: Bool) {
        c(provideEnabled)
    }
}

private class ProvidePausedChangeListener: NSObject, SdkProvidePausedChangeListenerProtocol {
    
    private let c: (_ providePaused: Bool) -> Void

    init(c: @escaping (_ providePaused: Bool) -> Void) {
        self.c = c
    }
    
    func providePausedChanged(_ providePaused: Bool) {
        c(providePaused)
    }
}

private class OfflineChangeListener: NSObject, SdkOfflineChangeListenerProtocol {
    
    private let c: (_ offline: Bool, _ vpnInterfaceWhileOffline: Bool) -> Void

    init(c: @escaping (_ offline: Bool, _ vpnInterfaceWhileOffline: Bool) -> Void) {
        self.c = c
    }
    
    func offlineChanged(_ offline: Bool, vpnInterfaceWhileOffline: Bool) {
        c(offline, vpnInterfaceWhileOffline)
    }
}

private class ConnectChangeListener: NSObject, SdkConnectChangeListenerProtocol {
    
    private let c: (_ connectEnabled: Bool) -> Void

    init(c: @escaping (_ connectEnabled: Bool) -> Void) {
        self.c = c
    }
    
    func connectChanged(_ connectEnabled: Bool) {
        c(connectEnabled)
    }
}

private class RemoteChangeListener: NSObject, SdkRemoteChangeListenerProtocol {
    
    private let c: (_ remoteConnected: Bool) -> Void

    init(c: @escaping (_ remoteConnected: Bool) -> Void) {
        self.c = c
    }
    
    func remoteChanged(_ remoteConnected: Bool) {
        c(remoteConnected)
    }
}

