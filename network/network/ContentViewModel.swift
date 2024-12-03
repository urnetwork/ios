//
//  ContentViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/30.
//

import Foundation
import URnetworkSdk


//extension ContentView {
//    
//    class ViewModel: ObservableObject {
//        
//        // for testing
//        @Published var isAuthenticated: Bool = false
//        
//        @Published private(set) var networkSpace: SdkNetworkSpace? {
//            didSet {
//                print("network space set: get api url: \(networkSpace?.getApiUrl() ?? "none")")
//                setApi(networkSpace?.getApi())
//            }
//        }
//        
//        @Published private(set) var api: SdkBringYourApi?
//        
//        func setApi(_ api: SdkBringYourApi?) {
//            print("should set api as: \(api)")
//            self.api = api
//        }
//        
//    }
//    
//}

//private class TestNetworkSpaceUpdateCallback: NSObject, URnetworkSdk.SdkNetworkSpaceUpdateProtocol {
//    func update(_ values: URnetworkSdk.SdkNetworkSpaceValues?) {
//        print("⭐️ Update callback triggered")
//        
//        guard let values = values else {
//            print("❌ No values provided to update")
//            return
//        }
//        
//        // todo - these should be moved into a build config and loaded dynamically
//        print("📝 Setting new values...")
////        values.envSecret = ""
////        values.bundled = true
////        values.netExposeServerIps = true
////        values.netExposeServerHostNames = true
////        values.linkHostName = "ur.io"
////        values.migrationHostName = "bringyour.com"
////        values.store = ""
////        values.wallet = "circle"
////        values.ssoGoogle = false
//        
//        // print("✅ Values updated")
//    }
//}

//extension ContentView.ViewModel {
//    
//    func initializeNetworkSpace(_ storagePath: String) {
//        
//        print("initializing network space")
//        
//        let networkSpaceManager = URnetworkSdk.SdkNewNetworkSpaceManager(storagePath)
//        
//        
//        let callback = TestNetworkSpaceUpdateCallback()
//        
//        let networkSpaceValues = SdkNetworkSpaceValues()
//        // networkSpaceValues.
//        networkSpaceValues.envSecret = ""
//        networkSpaceValues.bundled = true
//        networkSpaceValues.netExposeServerIps = true
//        networkSpaceValues.netExposeServerHostNames = true
//        networkSpaceValues.linkHostName = "ur.io"
//        networkSpaceValues.migrationHostName = "bringyour.com"
//        networkSpaceValues.store = ""
//        networkSpaceValues.wallet = "circle"
//        networkSpaceValues.ssoGoogle = false
//        
//        callback.update(networkSpaceValues)
//        
//        let hostName = "ur.network"
//        let envName = "main"
//        let networkSpaceKey = URnetworkSdk.SdkNewNetworkSpaceKey(hostName, envName)
//        
//        networkSpaceManager?.updateNetworkSpace(networkSpaceKey, callback: callback)
//        
//        networkSpace = networkSpaceManager?.getNetworkSpace(networkSpaceKey)
//        
//    }
//    
//}
