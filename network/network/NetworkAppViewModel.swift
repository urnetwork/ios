//
//  NetworkAppViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/29.
//

import Foundation
import URnetworkSdk


extension NetworkApp {
    
    class ViewModel: ObservableObject {
        
        @Published private(set) var asyncLocalState: SdkAsyncLocalState? = NetworkSpaceManager.shared.networkSpace?.getAsyncLocalState() {
            didSet {
                handleAsyncLocalStateChange()
            }
        }
        
        // for testing
        @Published var isAuthenticated: Bool = false
        
        @Published private(set) var device: SdkBringYourDevice? {
            didSet {
                api = device?.getApi()
            }
        }
        
        @Published private(set) var api: SdkBringYourApi?
        
        // @Published private(set) var asyncLocalState: SdkAsyncLocalState?
        
        func setDevice(_ device: SdkBringYourDevice?) {
            self.device = device
        }
        
        func setAsyncLocalState(_ asyncLocalState: SdkAsyncLocalState?) {
            self.asyncLocalState = asyncLocalState
        }
        
        func logout() {}
        
        func initDevice(_ jwt: String) {}
        
//        var routeLocal: Bool = device?.getRouteLocal() ?? false {
//            didSet {
//                device?.setRouteLocal(routeLocal)
//                asyncLocalState?.getLocalState()?.setRouteLocal(routeLocal)
//            }
//        }
        
        init() {
            
        }
        
    }
    
}

// MARK: - AsyncLocalState
extension NetworkApp.ViewModel {
    
    private func handleAsyncLocalStateChange() {
        if let jwt = asyncLocalState?.getLocalState()?.getByJwt() {
         
            if jwt == "" {
                logout()
            } else {
                initDevice(jwt)
            }
            
        } else {
            // should we log out here?
        }
    }
    
}

// MARK: - Device handling
extension NetworkApp.ViewModel {
    
//    var routeLocal: Bool = device?.getRouteLocal() ?? false {
//        didSet {
//            device?.setRouteLocal(routeLocal)
//        }
//    }
    
}
