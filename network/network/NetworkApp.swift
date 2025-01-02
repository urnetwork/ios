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
    @StateObject private var snackbarManager = UrSnackbarManager()
    
    var body: some Scene {
        WindowGroup {
            
            ContentView()
                .environmentObject(ThemeManager.shared)
                .environmentObject(snackbarManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
