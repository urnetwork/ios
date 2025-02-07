//
//  MainNavigationSplitView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/02/08.
//

import SwiftUI
import URnetworkSdk

enum MainNavigationTab {
    case connect
    case account
    case support
}

struct MainNavigationSplitView: View {
    
    // @State private var selectedTab = 0
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var selectedTab: MainNavigationTab = .connect
    
    var api: SdkApi
    var device: SdkDeviceRemote
    var logout: () -> Void
    var connectViewController: SdkConnectViewController?
    @Binding var provideWhileDisconnected: Bool
    
    var vpnManager: VPNManager
    
    // can probably pass this down from MainView
    @StateObject var providerListSheetViewModel: ProviderListSheetViewModel = ProviderListSheetViewModel()
    
    init(
        api: SdkApi,
        device: SdkDeviceRemote,
        vpnManager: VPNManager,
        logout: @escaping () -> Void,
        provideWhileDisconnected: Binding<Bool>
    ) {
        self.api = api
        self.logout = logout
        self.device = device
        self._provideWhileDisconnected = provideWhileDisconnected
        self.connectViewController = device.openConnectViewController()
        
        // vpn manager
//        self.vpnManager = VPNManager(device: device)
        self.vpnManager = vpnManager
        // vpnManager.loadOrCreateManager()

    }
    
    var body: some View {
        
        NavigationSplitView {
            List(selection: $selectedTab) {
                
                HStack {

                    Image(selectedTab == .connect ? "ur.symbols.tab.connect.fill" : "ur.symbols.tab.connect")
                        .renderingMode(.template)

                    Text("Connect")
                    
                }
                .foregroundColor(themeManager.currentTheme.textColor)
                .tag(MainNavigationTab.connect)
                
                HStack {
                    
                    Image(selectedTab == .account ? "ur.symbols.tab.account.fill" : "ur.symbols.tab.account")
                        .renderingMode(.template)
                                            
                    Text("Account")
                    
                }
                .foregroundColor(themeManager.currentTheme.textColor)
                .tag(MainNavigationTab.account)
                
                HStack {
                    
                    Image(selectedTab == .support ? "ur.symbols.tab.support.fill" : "ur.symbols.tab.support")
                        .renderingMode(.template)
                    
                    Text("Support")
                    
                }
                .foregroundColor(themeManager.currentTheme.textColor)
                .tag(MainNavigationTab.support)
                
            }
        }
//        content: {
//            
//        }
        detail: {
            
            switch selectedTab {
            case .connect:
                ConnectView(
                    api: api,
                    logout: logout,
                    device: device,
                    connectViewController: connectViewController,
                    providerListSheetViewModel: providerListSheetViewModel
                )
                .background(themeManager.currentTheme.backgroundColor)
            case .account:
                AccountNavStackView(
                    api: api,
                    device: device,
                    provideWhileDisconnected: $provideWhileDisconnected,
                    logout: logout
                )
                .background(themeManager.currentTheme.backgroundColor)
            case .support:
                FeedbackView(
                    api: api
                )
                .background(themeManager.currentTheme.backgroundColor)
                .tabItem {
                    VStack {
                        Image(selectedTab == .support ? "ur.symbols.tab.support.fill" : "ur.symbols.tab.support")
                            .renderingMode(.template)
                        
                        Text("Support")
                            
                    }
                    .foregroundColor(themeManager.currentTheme.textColor)
                }
            }
            
        }
        
    }
}

//#Preview {
//    MainNavigationSplitView()
//}
