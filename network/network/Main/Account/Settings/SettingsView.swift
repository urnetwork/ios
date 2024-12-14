//
//  SettingsView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import SwiftUI
import URnetworkSdk

struct SettingsView: View {
    
    @StateObject private var viewModel: ViewModel
    @StateObject var accountPreferencesViewModel: AccountPreferencesViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var snackbarManager: UrSnackbarManager
    
    var clientId: SdkId?
    @Binding var provideWhileDisconnected: Bool
    
    var clientUrl: String {
        guard let clientId = clientId?.idStr else { return "" }
        return "https://ur.io/c?\(clientId)"
    }
    
    init(
        clientId: SdkId?,
        provideWhileDisconnected: Binding<Bool>,
        accountPreferencesViewModel: AccountPreferencesViewModel,
        api: SdkBringYourApi?
    ) {
        _viewModel = StateObject.init(wrappedValue: ViewModel(
            api: api
        ))
        self.clientId = clientId
        self._provideWhileDisconnected = provideWhileDisconnected
        self._accountPreferencesViewModel = StateObject(wrappedValue: accountPreferencesViewModel)
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ScrollView(.vertical) {
                
                VStack {
                    
                    HStack {
                        Text("Settings")
                            .font(themeManager.currentTheme.titleFont)
                            .foregroundColor(themeManager.currentTheme.textColor)
                        
                        Spacer()
                    }
                    
                    Spacer().frame(height: 64)
                    
                    HStack {
                        UrLabel(text: "Plan")
                        
                        Spacer()
                    }
                    
                    HStack {
                        
                        Text("URnetwork Member")
                            .font(themeManager.currentTheme.bodyFont)
                            .foregroundColor(themeManager.currentTheme.textColor)
                        
                        
                        Spacer()
                        Button(action: {}) {
                            Text("Change")
                        }
                        
                    }
                    
                    Spacer().frame(height: 32)
                    
                    HStack {
                        UrLabel(text: "URid")
                        
                        Spacer()
                    }
                    
                    /**
                     * Copy URid
                     */
                    // TODO: copy URid
                    Button(action: {
                        if let clientId = clientId?.idStr {
                            UIPasteboard.general.string = clientId
                            
                            snackbarManager.showSnackbar(message: "URid copied to clipboard")
                        }
                    }) {
                        HStack {
                            Text(clientId?.idStr ?? "")
                                .font(themeManager.currentTheme.secondaryBodyFont)
                            Spacer()
                            Image(systemName: "document.on.document")
                        }
                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                    }
                    .background(themeManager.currentTheme.tintedBackgroundBase)
                    .cornerRadius(8)
                    
                    Spacer().frame(height: 32)
                    
                    /**
                     * Copy URnetwork link
                     */
                    HStack {
                        UrLabel(text: "Share URnetwork")
                        
                        Spacer()
                    }
                    
                    Button(action: {
                        if let clientId = clientId?.idStr {
                            UIPasteboard.general.string = "https://ur.io/c?\(clientId)"
                            
                            snackbarManager.showSnackbar(message: "URnetwork link copied to clipboard")
                            
                        }
                    }) {
                        HStack {
                            Text(clientUrl)
                                .font(themeManager.currentTheme.secondaryBodyFont)
                                .foregroundColor(themeManager.currentTheme.textMutedColor)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Spacer()
                            Image(systemName: "document.on.document")
                        }
                        .foregroundColor(themeManager.currentTheme.textMutedColor)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                    }
                    .background(themeManager.currentTheme.tintedBackgroundBase)
                    .cornerRadius(8)

                    Spacer().frame(height: 32)
                    
                    /**
                     * Connections
                     */
                    HStack {
                        UrLabel(text: "Connections")
                        
                        Spacer()
                    }
                    
                    UrSwitchToggle(isOn: $provideWhileDisconnected) {
                        Text("Provide while disconnected")
                            .font(themeManager.currentTheme.bodyFont)
                            .foregroundColor(themeManager.currentTheme.textColor)
                    }
                    
                    Spacer().frame(height: 32)
                    
                    /**
                     * Notifications
                     */
                    
                    HStack {
                        UrLabel(text: "Notifications")
                        
                        Spacer()
                    }
                    
                    UrSwitchToggle(isOn: $viewModel.canReceiveNotifications) {
                        Text("Receive connection notifications")
                            .font(themeManager.currentTheme.bodyFont)
                            .foregroundColor(themeManager.currentTheme.textColor)
                        
                    }
                    
                    Spacer().frame(height: 32)
                    
                    HStack {
                        UrLabel(text: "Stay in touch")
                        
                        Spacer()
                    }
                    
                    UrSwitchToggle(
                        isOn: $accountPreferencesViewModel.canReceiveProductUpdates,
                        isEnabled: !accountPreferencesViewModel.isUpdatingAccountPreferences
                    ) {
                        Text("Send me product updates")
                            .font(themeManager.currentTheme.bodyFont)
                            .foregroundColor(themeManager.currentTheme.textColor)
                        
                    }
                    
                    Spacer().frame(height: 16)
                    
                    HStack {
                        Text("Join the community on ")
                            .font(themeManager.currentTheme.bodyFont)
                            .foregroundColor(themeManager.currentTheme.textColor)
                        + Text("[Discord](https://discord.com/invite/RUNZXMwPRK)")
                            .font(themeManager.currentTheme.bodyFont)
                            .foregroundColor(themeManager.currentTheme.accentColor)
                        
                        Spacer()
                        
                        Button(action: {
                            if let url = URL(string: "https://discord.com/invite/RUNZXMwPRK") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image(systemName: "arrow.forward")
                                .foregroundColor(themeManager.currentTheme.textColor)
                        }
                    }
                    
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .frame(minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
                
                
            }
        }
    }
}

#Preview {
    
    let themeManager = ThemeManager.shared
    let accountPreferenceViewModel = AccountPreferencesViewModel(api: SdkBringYourApi())
    
    SettingsView(
        clientId: nil,
        provideWhileDisconnected: .constant(true),
        accountPreferencesViewModel: accountPreferenceViewModel,
        api: nil
    )
    .environmentObject(themeManager)
    .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
}
