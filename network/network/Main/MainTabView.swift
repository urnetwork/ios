//
//  MainTabView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import SwiftUI
import URnetworkSdk

struct MainTabView: View {
    
    var api: SdkBringYourApi
    var logout: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            /**
             * Connect View
             */
            ConnectView(
                logout: logout
            )
            .tabItem {
                Image(selectedTab == 0 ? "ur.symbols.tab.connect.fill" : "ur.symbols.tab.connect")
                    .renderingMode(.template)
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                // Label("Connect", systemImage: "person.circle")
            }
            .tag(0)
            
            /**
             * Account View
             */
            AccountView(
                api: api
            )
            .tabItem {
//                Label("Account", systemImage: "person.circle")
                Image(selectedTab == 1 ? "ur.symbols.tab.account.fill" : "ur.symbols.tab.account")
                    .renderingMode(.template)
                    .foregroundColor(themeManager.currentTheme.textColor)
            }
            .tag(1)
            
            /**
             * Feedback View
             */
            FeedbackView(
                api: api
            )
            .tabItem {
                Image(selectedTab == 2 ? "ur.symbols.tab.support.fill" : "ur.symbols.tab.support")
                    .renderingMode(.template)
                    .foregroundColor(themeManager.currentTheme.textColor)
                // Label("Support", systemImage: "person.circle")
            }
            .tag(2)
                
        }
        
    }
}

#Preview {
    MainTabView(
        api: SdkBringYourApi(),
        logout: {}
    )
}
