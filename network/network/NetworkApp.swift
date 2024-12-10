//
//  NetworkApp.swift
//  network
//
//  Created by brien on 11/18/24.
//

import SwiftUI
import URnetworkSdk
import GoogleSignIn

@main
struct NetworkApp: App {
    
    @StateObject var networkStore = NetworkStore()
    @StateObject private var snackbarManager = UrSnackbarManager()
    
    var body: some Scene {
        WindowGroup {
            
            ZStack {
                
                if let api = networkStore.api {
                    
                    if networkStore.device != nil {
                        
                        MainTabView(api: api, logout: networkStore.logout)
                        
                    } else {
                        
                        
                        LoginNavigationView(
                            api: api,
                            authenticateNetworkClient: networkStore.authenticateNetworkClient
                        )
                        
                        
                    }
                } else {
                    // loading indicator?
                }
                
                UrSnackBar(message: snackbarManager.message, isVisible: snackbarManager.isVisible)
                    .padding(.bottom, 50)
                
            }
            .environmentObject(ThemeManager.shared)
            .environmentObject(snackbarManager)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
