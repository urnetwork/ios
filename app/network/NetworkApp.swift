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
    
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #elseif os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    let themeManager = ThemeManager.shared
    
    @StateObject var deviceManager = DeviceManager()
    
    var body: some Scene {
        WindowGroup {
            
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(deviceManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .preferredColorScheme(.dark)
                .background(themeManager.currentTheme.backgroundColor)
        }
        .commands {
            
            /**
             * macOS menu items
             */
            
            if deviceManager.device != nil {
             
                CommandMenu("Account") {
                    Button("Sign out") {
                        deviceManager.logout()
                    }
                }
                
            }
            
        }
    }
}
