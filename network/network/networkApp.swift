//
//  networkApp.swift
//  network
//
//  Created by brien on 11/18/24.
//

import SwiftUI
import URnetworkSdk

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
}

@main
struct networkApp: App {
    
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            
            if authManager.isAuthenticated {
                
                TabView {
                    
                    ConnectView()
                        .tabItem {
                            Label("Account", systemImage: "person.circle")
                        }
                        
                }
                .background(ThemeManager.shared.currentTheme.systemBackground.ignoresSafeArea())
                .environmentObject(ThemeManager.shared)
                
            } else {
                
                LoginNavigationView()
                    .environmentObject(ThemeManager.shared)
                
            }
        }
    }
}
