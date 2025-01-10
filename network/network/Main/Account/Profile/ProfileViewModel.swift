//
//  ProfileViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import Foundation
import URnetworkSdk

extension ProfileView {
    
    class ViewModel: ObservableObject {
        
        var api: SdkApi
        
        init(api: SdkApi) {
            self.api = api
        }
        
    }
    
}
