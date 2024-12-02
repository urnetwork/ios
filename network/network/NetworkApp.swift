//
//  NetworkApp.swift
//  network
//
//  Created by brien on 11/18/24.
//

import SwiftUI
import URnetworkSdk

//class MainUrNetworkStore: ObservableObject {
////    @Published var networkSpaceStore: NetworkSpaceStore
////    
////    init() {
////        self.networkSpaceStore = NetworkSpaceStore()
////    }
//}


@main
struct NetworkApp: App {
    
    @StateObject var networkStore = NetworkStore()
    
    var body: some Scene {
        WindowGroup {
            
            Group {
                
                if networkStore.device != nil {
                    
                    TabView {
                        
                        ConnectView(
                            logout: networkStore.logout
                        )
                            .tabItem {
                                Label("Account", systemImage: "person.circle")
                            }
                            
                    }
                    
                } else {
                    
                    if let api = networkStore.api {
                        LoginNavigationView(
                            api: api,
                            authenticateNetworkClient: networkStore.authenticateNetworkClient
                        )
                    }
//                    else {
//                        Text("loading api...")
//                    }
                    
                }
                
            }
            .environmentObject(ThemeManager.shared)
//            .onAppear {
//                let documentsPath = FileManager.default.urls(for: .documentDirectory,
//                                                           in: .userDomainMask)[0]
//                
//                print("documentsPath is \(documentsPath.path())")
//                
//                networkStore.initializeNetworkSpace(documentsPath.path())
//            }

        }
    }
}
