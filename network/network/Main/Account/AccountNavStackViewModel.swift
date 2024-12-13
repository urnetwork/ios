//
//  AccountViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import Foundation
import URnetworkSdk

enum AccountNavigationPath: Hashable {
//    case password(_ userAuth: String)
    case profile
    case settings
    case wallet
}

extension AccountNavStackView {
    
    class ViewModel: ObservableObject {
        
//        var api: SdkBringYourApi
//        
//        init(api: SdkBringYourApi) {
//            self.api = api
//        }
        
        @Published var navigationPath: [AccountNavigationPath] = []
        
        func navigate(_ path: AccountNavigationPath) {
            navigationPath.append(path)
        }

        func back() {
            if !navigationPath.isEmpty {
             navigationPath.removeLast()
            }
        }
        
    }
    
}
