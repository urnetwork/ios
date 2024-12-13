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
    @EnvironmentObject var themeManager: ThemeManager
    
    init(api: SdkBringYourApi?) {
        _viewModel = StateObject.init(wrappedValue: ViewModel(
            api: api
        ))
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
                    
                    UrSwitchToggle(isOn: $viewModel.canReceiveProductUpdates) {
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
    SettingsView(
        api: nil
    )
    .environmentObject(ThemeManager.shared)
}
