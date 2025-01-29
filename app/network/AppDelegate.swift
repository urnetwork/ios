//
//  AppDelegate.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/30.
//

import Foundation
import UIKit
import URnetworkSdk

class AppDelegate: UIResponder, UIApplicationDelegate {
    override init() {
        SdkSetMemoryLimit(64 * 1024 * 1024)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .allButUpsideDown
        } else {
            return .portrait
        }
    }
    
    
    
}

//func mainImmediateBlocking(callback: ()->Void) {
//    if Thread.isMainThread {
//        callback()
//    } else {
//        DispatchQueue.main.sync {
//            callback()
//        }
//    }
//}
