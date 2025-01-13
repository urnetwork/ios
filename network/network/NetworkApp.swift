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
    let themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            
            ContentView()
                .environmentObject(themeManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .preferredColorScheme(.dark)
                .background(themeManager.currentTheme.backgroundColor)
        }
    }
}
