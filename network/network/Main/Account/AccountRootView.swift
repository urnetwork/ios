//
//  AccountView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/13.
//

import SwiftUI
import URnetworkSdk

struct AccountRootView: View {
    
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var deviceManager: DeviceManager
    
    var navigate: (AccountNavigationPath) -> Void
    var logout: () -> Void
    var api: SdkApi

    
    @StateObject private var viewModel: ViewModel = ViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager()
    
    init(
        navigate: @escaping (AccountNavigationPath) -> Void,
        logout: @escaping () -> Void,
        api: SdkApi
    ) {
        self.navigate = navigate
        self.logout = logout
        self.api = api
    }
    
    
    var body: some View {
        
        let isGuest = deviceManager.parsedJwt?.guestMode ?? true

        VStack {
            
            HStack {
                Text("Account")
                    .font(themeManager.currentTheme.titleFont)
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                Spacer()
                
                AccountMenu(
                    isGuest: isGuest,
                    logout: logout,
                    api: api
                )
                
            }
            .frame(height: 32)
            // .padding(.vertical, 12)
            
            Spacer().frame(height: 16)
            
            VStack(spacing: 0) {
                
                HStack {
                    Text("Plan")
                        .font(themeManager.currentTheme.secondaryBodyFont)
                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                    Spacer()
                }
                
                HStack(alignment: .firstTextBaseline) {
                    
                    Text("Guest")
                        .font(themeManager.currentTheme.titleCondensedFont)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.isPresentedUpgradeSheet = true
                    }) {
                        Text("Create account")
                            .font(themeManager.currentTheme.secondaryBodyFont)
                    }
                    
                }
                
                Divider()
                    .background(themeManager.currentTheme.borderBaseColor)
                    .padding(.vertical, 16)
                
                HStack {
                    Text("Earnings")
                        .font(themeManager.currentTheme.secondaryBodyFont)
                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                    Spacer()
                }
                
                HStack(alignment: .firstTextBaseline) {
                    
                    Text("0")
                        .font(themeManager.currentTheme.titleCondensedFont)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    Text("USDC")
                        .font(themeManager.currentTheme.secondaryBodyFont)
                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("Start earning")
                            .font(themeManager.currentTheme.secondaryBodyFont)
                    }
                    
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(themeManager.currentTheme.tintedBackgroundBase)
            .cornerRadius(12)
            
            Spacer().frame(height: 16)
            
            /**
             * Navigation items
             */
            VStack(spacing: 0) {
                AccountNavLink(
                    name: "Profile",
                    iconPath: "ur.symbols.user.circle",
                    action: {
                        
                        if isGuest {
                            viewModel.isPresentedCreateAccount = true
                        } else {
                            navigate(.profile)
                        }
                        
                    }
                )
                AccountNavLink(
                    name: "Settings",
                    iconPath: "ur.symbols.sliders",
                    action: {
                        if isGuest {
                            viewModel.isPresentedCreateAccount = true
                        } else {
                            navigate(.settings)
                        }
                    }
                )
                AccountNavLink(
                    name: "Wallet",
                    iconPath: "ur.symbols.wallet",
                    action: {
                        if isGuest {
                            viewModel.isPresentedCreateAccount = true
                        } else {
                            navigate(.wallets)
                        }
                    }
                )
                
                ReferralShareLink(api: api) {
                    
                    VStack(spacing: 0) {
                        HStack {
                            
                            Image("ur.symbols.heart")
                                .foregroundColor(themeManager.currentTheme.textMutedColor)
                            
                            Spacer().frame(width: 16)
                            
                            Text("Refer and earn")
                                .font(themeManager.currentTheme.bodyFont)
                                .foregroundColor(themeManager.currentTheme.textColor)
                            
                            Spacer()
                            
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                            .background(themeManager.currentTheme.borderBaseColor)
                        
                    }
                    
                }
                
                Button(action: {
                    openURL(URL(string: "https://apps.apple.com/app/id6446097114?action=write-review")!)
                }) {
                    
                    VStack(spacing: 0) {
                        HStack {
                            
                            Image(systemName: "pencil")
                                .foregroundColor(themeManager.currentTheme.textMutedColor)
                            
                            Spacer().frame(width: 16)
                            
                            Text("Review URnetwork")
                                .font(themeManager.currentTheme.bodyFont)
                                .foregroundColor(themeManager.currentTheme.textColor)
                            
                            Spacer()
                            
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                            .background(themeManager.currentTheme.borderBaseColor)
                        
                    }
                    
                }
                
            }
            
            Spacer()
            
            if isGuest {
                UrButton(
                    text: "Create an account",
                    action: {
                        viewModel.isPresentedCreateAccount = true
                    }
                )
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .onChange(of: deviceManager.device) {
//            viewModel.isPresentedCreateAccount = false
//        }
        .sheet(isPresented: $viewModel.isPresentedUpgradeSheet) {
            UpgradeSubscriptionSheet(
                subscriptionProduct: subscriptionManager.products.first,
                purchase: { product in
                    subscriptionManager.purchase(
                        product: product,
                        onSuccess: {
                            print("on success called")
                            viewModel.isPresentedUpgradeSheet = false
                        }
                    )
                }
            )
        }
        .fullScreenCover(isPresented: $viewModel.isPresentedCreateAccount) {
            LoginNavigationView(
                api: api,
                cancel: {
                    viewModel.isPresentedCreateAccount = false
                },
                
                handleSuccess: { jwt in
                    
                }
                
//                onSuccess: {
//                    viewModel.isPresentedCreateAccount = false
//                }
            )
        }
//        .fullScreenCover(isPresented: $viewModel.isPresentedReferralSheet) {
//            NavigationView {
//                ReferSheet(api: api)
//                    .toolbar {
//                        ToolbarItem(placement: .destructiveAction) {
//                            Button(action: {
//                                viewModel.isPresentedReferralSheet = false
//                            }) {
//                                Image(systemName: "xmark")
//                            }
//                        }
//                    }
//            }
//        
//        }
    }
}

private struct AccountNavLink: View {
    
    var name: String
    var iconPath: String
    var action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            
            VStack(spacing: 0) {
                HStack {
                    
                    Image(iconPath)
                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                    
                    Spacer().frame(width: 16)
                    
                    Text(name)
                        .font(themeManager.currentTheme.bodyFont)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    Spacer()
                    
                    Image("ur.symbols.caret.right")
                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                    
                }
                .padding(.vertical, 8)
                
                Divider()
                    .background(themeManager.currentTheme.borderBaseColor)
                
            }
            
        }
        
    }
}

//#Preview {
//    
//    let themeManager = ThemeManager.shared
//    
//    VStack {
//        AccountRootView(
//            navigate: {_ in},
//            logout: {},
//            api: SdkBringYourApi()
//        )
//    }
//    .environmentObject(themeManager)
//    .background(themeManager.currentTheme.backgroundColor)
//    .frame(maxHeight: .infinity)
//    
//}
