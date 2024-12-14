//
//  SettingsViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import Foundation
import URnetworkSdk
import UserNotifications

extension SettingsView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        @Published var canReceiveNotifications: Bool = false {
            didSet {
                if canReceiveNotifications == true {
                    requestNotificationAuthorization()
                }
            }
        }
        
        let domain = "SettingsViewModel"
        
        init() {
            checkNotificationSettings()
        }
        
        private func checkNotificationSettings() {
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .notDetermined:
                    print("Notification permission not determined.")
                case .denied:
                    print("Notification permission denied.")
                case .authorized, .provisional, .ephemeral:
                    print("Notification permission granted.")
                    self.canReceiveNotifications = true
                @unknown default:
                    print("Unknown notification settings.")
                }
            }
        }
        
        private func requestNotificationAuthorization() {
            
            print("requestNotificationAuthorization hit")
            
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    // Handle the error here.
                    print("Error requesting authorization: \(error.localizedDescription)")
                }
                
                if !granted {
                    print("Notification authorization denied.")
                    DispatchQueue.main.async {
                        self.canReceiveNotifications = false
                    }
                }
            }
            
            
        }
        
    }
    
}
