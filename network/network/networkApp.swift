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
    
    init() {
        
        // Get app's document directory path
        let documentsPath = FileManager.default.urls(for: .documentDirectory,
                                                   in: .userDomainMask)[0]
        
        // Print for debugging
        print("📁 Documents path: \(documentsPath.path)")
        
        NetworkSpaceManager.shared.initialize(with: documentsPath.path())
        
    }
    
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
