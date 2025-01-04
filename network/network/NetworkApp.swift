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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var globalStore = GlobalStore()
    @StateObject private var snackbarManager = UrSnackbarManager()
    
    var body: some Scene {
        WindowGroup {
            
            ZStack {
                
                if let api = globalStore.api {
                    
                    if let device = globalStore.device {
                        
                        MainTabView(
                            api: api,
                            device: device,
                            logout: globalStore.logout,
                            provideWhileDisconnected: $globalStore.provideWhileDisconnected
                        )
                        
                    } else {
                        
                        LoginNavigationView(
                            api: api,
                            authenticateNetworkClient: globalStore.authenticateNetworkClient
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
            .environmentObject(globalStore)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
