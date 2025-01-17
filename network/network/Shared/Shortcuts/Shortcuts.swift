//
//  Shortcuts.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/17.
//

import Foundation
import AppIntents

struct Shortcuts: AppShortcutsProvider {
    
    static var appShortcuts: [AppShortcut] {
        
        AppShortcut(
            intent: ConnectIntent(),
            phrases: [
                "Connect to \(.applicationName)",
                "Connect \(.applicationName)",
                "Connect \(.applicationName) VPN",
                "Connect to \(.applicationName) VPN",
                "Connect VPN to \(.applicationName)"
            ],
            shortTitle: "Connect VPN",
            // TODO: update systemImageName
            systemImageName: "pin"
        )
        
    }
    
}
