//
//  AccountViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/13.
//

import Foundation
import URnetworkSdk

extension AccountView {
    
    class ViewModel: ObservableObject {
        var api: SdkBringYourApi
        
        init(api: SdkBringYourApi) {
            self.api = api
        }
    }
    
}

