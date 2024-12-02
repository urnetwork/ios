//
//  NetworkSpaceStore.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/30.
//

import Foundation
import SwiftUI
import URnetworkSdk

private class TestNetworkSpaceUpdateCallback: NSObject, URnetworkSdk.SdkNetworkSpaceUpdateProtocol {
    func update(_ values: URnetworkSdk.SdkNetworkSpaceValues?) {
        print("⭐️ Update callback triggered")
        
        guard let values = values else {
            print("❌ No values provided to update")
            return
        }
        
        // todo - these should be moved into a build config and loaded dynamically
        print("📝 Setting new values...")
//        values.envSecret = ""
//        values.bundled = true
//        values.netExposeServerIps = true
//        values.netExposeServerHostNames = true
//        values.linkHostName = "ur.io"
//        values.migrationHostName = "bringyour.com"
//        values.store = ""
//        values.wallet = "circle"
//        values.ssoGoogle = false
        
        // print("✅ Values updated")
    }
}

class NetworkSpaceStore: ObservableObject {
    
    // @Published private(set) var networkSpace: SdkNetworkSpace?
    private var networkSpace: SdkNetworkSpace?
    
    var api: SdkBringYourApi? {
        return networkSpace?.getApi()
    }
    
    func initialize(_ storagePath: String) {
        let networkSpaceManager = URnetworkSdk.SdkNewNetworkSpaceManager(storagePath)
        
        let callback = TestNetworkSpaceUpdateCallback()
        
        let networkSpaceValues = SdkNetworkSpaceValues()
        // networkSpaceValues.
        networkSpaceValues.envSecret = ""
        networkSpaceValues.bundled = true
        networkSpaceValues.netExposeServerIps = true
        networkSpaceValues.netExposeServerHostNames = true
        networkSpaceValues.linkHostName = "ur.io"
        networkSpaceValues.migrationHostName = "bringyour.com"
        networkSpaceValues.store = ""
        networkSpaceValues.wallet = "circle"
        networkSpaceValues.ssoGoogle = false
        
        callback.update(networkSpaceValues)
        
        let hostName = "ur.network"
        let envName = "main"
        let networkSpaceKey = URnetworkSdk.SdkNewNetworkSpaceKey(hostName, envName)
        
        networkSpaceManager?.updateNetworkSpace(networkSpaceKey, callback: callback)
        
        networkSpace = networkSpaceManager?.getNetworkSpace(networkSpaceKey)
    }
    
}

