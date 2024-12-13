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
    
    init(api: SdkBringYourApi, logout: @escaping () -> Void) {
        self.api = api
        self.logout = logout
        setupTabBar()
    }
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            /**
             * Connect View
             */
            ConnectView(
                api: api,
                logout: logout
            )
            .background(themeManager.currentTheme.backgroundColor)
            .tabItem {
                Image(selectedTab == 0 ? "ur.symbols.tab.connect.fill" : "ur.symbols.tab.connect")
                    .renderingMode(.template)
                    .foregroundColor(themeManager.currentTheme.textColor)
            }
            .tag(0)
            
            /**
             * Account View
             */
            AccountNavStackView(
                api: api
            )
            .background(themeManager.currentTheme.backgroundColor)
            .tabItem {
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
            .background(themeManager.currentTheme.backgroundColor)
            .tabItem {
                Image(selectedTab == 2 ? "ur.symbols.tab.support.fill" : "ur.symbols.tab.support")
                    .renderingMode(.template)
                    .foregroundColor(themeManager.currentTheme.textColor)
            }
            .tag(2)
                
        }
        
    }
    
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.shadowColor = UIColor(white: 1.0, alpha: 0.12)
        // appearance.shadowImage = UIImage(named: "tab-shadow")?.withRenderingMode(.alwaysTemplate)
        // appearance.backgroundColor = UIColor(hex: "#101010")
        
        appearance.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1)
        
        
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
    }
    
}

#Preview {
    MainTabView(
        api: SdkBringYourApi(),
        logout: {}
    )
    .environmentObject(ThemeManager.shared)
}
