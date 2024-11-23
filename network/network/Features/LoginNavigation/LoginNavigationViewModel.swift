//
//  LoginNavigationViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import Foundation

enum LoginInitialNavigationPath: Hashable {
    // case initial
    case password(_ userAuth: String)
    case createNetwork(_ userAuth: String)
}

extension LoginNavigationView {
    
    class ViewModel: ObservableObject {
        
        @Published var navigationPath: [LoginInitialNavigationPath] = []
        
        func navigate(_ path: LoginInitialNavigationPath) {
            print("navigate hit")
            // navigationPath = .password(userAuth)
            // navigationPath.append(.password("hello@ur.io"))
            navigationPath.append(path)
        }

        // can be used in custom back button        
        // func back() {
        //     if !navigationPath.isEmpty {
        //         navigationPath.removeLast()
        //     }
        // }
    }
}
