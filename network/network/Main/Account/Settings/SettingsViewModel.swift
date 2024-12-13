//
//  SettingsViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import Foundation
import URnetworkSdk

extension SettingsView {
    
    class ViewModel: ObservableObject {
        
        @Published var canReceiveNotifications: Bool = false
        @Published var canReceiveProductUpdates: Bool = false
        @Published var canProvideWhileDisconnected: Bool = false
        
        var api: SdkBringYourApi?
        
        init(api: SdkBringYourApi?) {
            self.api = api
        }
        
    }
    
}
