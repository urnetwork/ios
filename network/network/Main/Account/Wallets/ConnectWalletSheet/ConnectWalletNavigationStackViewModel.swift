//
//  ConnectWalletNavigationStackViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/09.
//

import Foundation

enum ConnectWalletNavigationPath: Hashable {
    // case wallets
    case external
}

extension ConnectWalletNavigationStack {
    
    class ViewModel: ObservableObject {
        
        @Published var connectWalletNavigationPath: [ConnectWalletNavigationPath] = []
        
        func navigate(_ path: ConnectWalletNavigationPath) {
            connectWalletNavigationPath.append(path)
        }

        func back() {
            if !connectWalletNavigationPath.isEmpty {
                connectWalletNavigationPath.removeLast()
            }
        }
        
    }
    
}
