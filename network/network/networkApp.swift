//
//  networkApp.swift
//  network
//
//  Created by brien on 11/18/24.
//

import SwiftUI
import URnetworkSdk

@main
struct networkApp: App {
    
    // @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
        WindowGroup {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    ContentView()
                        .environmentObject(ThemeManager.shared)
                }
                .background(ThemeManager.shared.currentTheme.systemBackground.ignoresSafeArea())
            } else {
                // Fallback on earlier versions
            } // Set background for the entire stack
        }
    }
    
}
