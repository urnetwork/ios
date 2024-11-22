//
//  NetworkSpaceManager.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/22.
//

import Foundation
import URnetworkSdk

class NetworkSpaceUpdateCallback: NSObject, URnetworkSdk.SdkNetworkSpaceUpdateProtocol {
    func update(_ values: URnetworkSdk.SdkNetworkSpaceValues?) {
        print("⭐️ Update callback triggered")
        
        guard let values = values else {
            print("❌ No values provided to update")
            return
        }
        
        // todo - these should be moved into a build config and loaded dynamically
        print("📝 Setting new values...")
        values.envSecret = ""
        values.bundled = true
        values.netExposeServerIps = true
        values.netExposeServerHostNames = true
        values.linkHostName = "ur.io"
        values.migrationHostName = "bringyour.com"
        values.store = ""
        values.wallet = "circle"
        values.ssoGoogle = false
        
        print("✅ Values updated")
    }
}

final class NetworkSpaceManager {
    static let shared = NetworkSpaceManager()
    
    private var networkSpaceManager: URnetworkSdk.SdkNetworkSpaceManager? = nil
    private(set) var networkSpace: URnetworkSdk.SdkNetworkSpace? = nil
    
    private init() {}

    public func initialize(with storagePath: String) {
        networkSpaceManager = URnetworkSdk.SdkNewNetworkSpaceManager(storagePath)
        
        
        let callback = NetworkSpaceUpdateCallback()
        
        let hostName = "ur.network"
        let envName = "main"
        let networkSpaceKey = URnetworkSdk.SdkNewNetworkSpaceKey(hostName, envName)
        
        networkSpaceManager?.updateNetworkSpace(networkSpaceKey, callback: callback)
        
        networkSpace = networkSpaceManager?.getNetworkSpace(networkSpaceKey)
        
    }
}
