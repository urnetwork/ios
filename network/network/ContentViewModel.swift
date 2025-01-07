//
//  ContentViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/30.
//

import Foundation
import URnetworkSdk

enum ContentViewPath: Hashable {
    // case initial
    case uninitialized
    case authenticate
    case main
}

extension ContentView {
    
    class ViewModel: ObservableObject {
        
        @Published private(set) var contentViewPath: ContentViewPath = .uninitialized
        
        func updatePath(_ device: SdkBringYourDevice?) {
            print("update content view path hit. device exists: \(device != nil)")
            
            if device != nil {
                contentViewPath = .main
            } else {
                contentViewPath = .authenticate
            }
            
        }
        
    }
    
}
