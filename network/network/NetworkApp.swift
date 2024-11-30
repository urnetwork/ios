//
//  NetworkApp.swift
//  network
//
//  Created by brien on 11/18/24.
//

import SwiftUI
import URnetworkSdk

@main
struct NetworkApp: App {
    
    @StateObject private var viewModel = ViewModel()
    
    
    init() {
        
        // Get app's document directory path
        let documentsPath = FileManager.default.urls(for: .documentDirectory,
                                                   in: .userDomainMask)[0]
        
        // Print for debugging
        print("📁 Documents path: \(documentsPath.path)")
        
        NetworkSpaceManager.shared.initialize(with: documentsPath.path())
        
        
        viewModel.setAsyncLocalState(NetworkSpaceManager.shared.networkSpace?.getAsyncLocalState())
        
    }
    
    var body: some Scene {
        WindowGroup {
            
            if viewModel.isAuthenticated {
                
                TabView {
                    
                    ConnectView()
                        .tabItem {
                            Label("Account", systemImage: "person.circle")
                        }
                        
                }
                .environmentObject(ThemeManager.shared)
                
            } else {
                
                LoginNavigationView()
                    .environmentObject(ThemeManager.shared)
                
            }
        }
    }
}
