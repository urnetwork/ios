//
//  SettingsViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import Foundation
import URnetworkSdk

extension SettingsView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        @Published var canReceiveNotifications: Bool = false
        
        let domain = "SettingsViewModel"
        
        var api: SdkBringYourApi?
        
        init(api: SdkBringYourApi?) {
            self.api = api
        }
        
    }
    
}
