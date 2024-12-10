//
//  WalletViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import Foundation
import URnetworkSdk

extension WalletView {
    
    class ViewModel: ObservableObject {
        
        var api: SdkBringYourApi
        
        init(api: SdkBringYourApi) {
            self.api = api
        }
        
    }
    
}
