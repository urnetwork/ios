//
//  ContentView.swift
//  network
//
//  Created by brien on 11/18/24.
//

import SwiftUI
import URnetworkSdk

struct ContentView: View {
    
    var api: SdkBringYourApi?
    
    @StateObject var viewModel = ViewModel()
    
    @EnvironmentObject var themeManager: ThemeManager
    
//    init() {
//        // Get app's document directory path
//        let documentsPath = FileManager.default.urls(for: .documentDirectory,
//                                                   in: .userDomainMask)[0]
//        
//        // Print for debugging
//        print("📁 Documents path: \(documentsPath.path)")
//        
//        // NetworkSpaceManager.shared.initialize(with: documentsPath.path())
//        viewModel.initializeNetworkSpace(documentsPath.path())
//    }
    
    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text(
//                "Hello, world!"
//            )
//            .foregroundStyle(.white)
//            .font(themeManager.currentTheme.titleCondensedFont)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .padding()
//        // .background(Color("UrBlack"))
//        .background(themeManager.currentTheme.backgroundColor)
        
        VStack {
            if viewModel.isAuthenticated {
                
                TabView {
                    
//                    ConnectView(
//                        logout: networkStore.logout
//                    )
//                        .tabItem {
//                            Label("Account", systemImage: "person.circle")
//                        }
                    
                    Text("...")
                        
                }
                // .environmentObject(networkSpaceStore)
                
            } else {
                
                Text("zzz")
                
//                if let api = api {
//                    LoginNavigationView(api: api)
//                        // .environmentObject(ThemeManager.shared)
//                } else {
//                    Text("loading api...")
//                }
                    // .environmentObject(networkSpaceStore)
                
            }
        }
//        .onAppear {
//            initializeNetworkSpace()
//        }
        
    }
    
//    private func initializeNetworkSpace() {
//        // Get app's document directory path
//        let documentsPath = FileManager.default.urls(for: .documentDirectory,
//                                                   in: .userDomainMask)[0]
//        
//        // Print for debugging
//        print("📁 Documents path: \(documentsPath.path)")
//        
//        // NetworkSpaceManager.shared.initialize(with: documentsPath.path())
//        viewModel.initializeNetworkSpace(documentsPath.path())
//    }
    
}

#Preview {
    ContentView(
        api: SdkBringYourApi()
    )
        .environmentObject(ThemeManager.shared)
}
