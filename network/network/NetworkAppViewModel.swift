//
//  NetworkAppViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/29.
//

import Foundation
import URnetworkSdk


//extension NetworkApp {
//    
//    class ViewModel: ObservableObject {
//        
//        @Published private(set) var asyncLocalState: SdkAsyncLocalState? = NetworkSpaceManager.shared.networkSpace?.getAsyncLocalState() {
//            didSet {
//                handleAsyncLocalStateChange()
//            }
//        }
//        
//        @Published private(set) var networkSpace: SdkNetworkSpace? {
//            didSet {
//                setApi(networkSpace?.getApi())
//            }
//        }
//        
//        // for testing
//        @Published var isAuthenticated: Bool = false
//        
////        @Published private(set) var device: SdkBringYourDevice? {
////            didSet {
////                api = device?.getApi()
////            }
////        }
//        
//        @Published private(set) var device: SdkBringYourDevice?
//        
//        func setDevice(_ device: SdkBringYourDevice?) {
//            
//            self.device = device
//            
////            if self.device != nil {
////
////            }
//            
//        }
//        
//        
//        
//        @Published private(set) var api: SdkBringYourApi?
//        
//        func setApi(_ api: SdkBringYourApi?) {
//            self.api = api
//        }
//        
//        // @Published private(set) var asyncLocalState: SdkAsyncLocalState?
//        
////        func setDevice(_ device: SdkBringYourDevice?) {
////            self.device = device
////        }
//        
//        func setAsyncLocalState(_ asyncLocalState: SdkAsyncLocalState?) {
//            self.asyncLocalState = asyncLocalState
//        }
//        
//        func logout() {}
//        
//        func initDevice(_ jwt: String) {}
//        
////        var routeLocal: Bool = device?.getRouteLocal() ?? false {
////            didSet {
////                device?.setRouteLocal(routeLocal)
////                asyncLocalState?.getLocalState()?.setRouteLocal(routeLocal)
////            }
////        }
//        
//        init() {
//            
//        }
//        
//    }
//    
//}
//
//// MARK: - AsyncLocalState
//extension NetworkApp.ViewModel {
//    
//    private func handleAsyncLocalStateChange() {
//        if let jwt = asyncLocalState?.getLocalState()?.getByJwt() {
//         
//            if jwt == "" {
//                logout()
//            } else {
//                initDevice(jwt)
//            }
//            
//        } else {
//            // should we log out here?
//        }
//    }
//    
//}
//
//// MARK: - Device handling
//extension NetworkApp.ViewModel {
//    
////    var routeLocal: Bool = device?.getRouteLocal() ?? false {
////        didSet {
////            device?.setRouteLocal(routeLocal)
////        }
////    }
//    
//}
//
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
//
//// MARK: - NetworkSpace
////extension NetworkApp.ViewModel {
////    
////    func initializeNetworkSpace(_ storagePath: String) {
////        
////        let networkSpaceManager = URnetworkSdk.SdkNewNetworkSpaceManager(storagePath)
////        
////        
////        let callback = TestNetworkSpaceUpdateCallback()
////        
////        let networkSpaceValues = SdkNetworkSpaceValues()
////        // networkSpaceValues.
////        networkSpaceValues.envSecret = ""
////        networkSpaceValues.bundled = true
////        networkSpaceValues.netExposeServerIps = true
////        networkSpaceValues.netExposeServerHostNames = true
////        networkSpaceValues.linkHostName = "ur.io"
////        networkSpaceValues.migrationHostName = "bringyour.com"
////        networkSpaceValues.store = ""
////        networkSpaceValues.wallet = "circle"
////        networkSpaceValues.ssoGoogle = false
////        
////        callback.update(networkSpaceValues)
////        
////        let hostName = "ur.network"
////        let envName = "main"
////        let networkSpaceKey = URnetworkSdk.SdkNewNetworkSpaceKey(hostName, envName)
////        
////        networkSpaceManager?.updateNetworkSpace(networkSpaceKey, callback: callback)
////        
////        networkSpace = networkSpaceManager?.getNetworkSpace(networkSpaceKey)
////        
////    }
////    
////}
