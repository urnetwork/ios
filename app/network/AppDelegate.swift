//
//  AppDelegate.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/30.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import URnetworkSdk

#if os(iOS)
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    override init() {
        SdkSetMemoryLimit(64 * 1024 * 1024)
    }
    
    // this is supposed to show Launch screen only on iOS but is breaking
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Use LaunchScreen storyboard on iOS
//        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
//        let initialViewController = storyboard.instantiateInitialViewController()
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = initialViewController
//        window?.makeKeyAndVisible()
//        return true
//    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .allButUpsideDown
        } else {
            return .portrait
        }
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        SdkFreeMemory()
    }
}
#elseif os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    override init() {
        SdkSetMemoryLimit(64 * 1024 * 1024)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // macOS specific initialization
    }
    
    func applicationDidReceiveMemoryWarning(_ notification: Notification) {
        SdkFreeMemory()
    }
}
#endif

//func mainImmediateBlocking(callback: ()->Void) {
//    if Thread.isMainThread {
//        callback()
//    } else {
//        DispatchQueue.main.sync {
//            callback()
//        }
//    }
//}
