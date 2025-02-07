//
//  ViewControllerUtils.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/06.
//

import Foundation
//import UIKit
//
//func getRootViewController() -> UIViewController? {
//    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//          let rootViewController = windowScene.windows.first?.rootViewController else {
//        return nil
//    }
//    return rootViewController
//}



#if canImport(UIKit)
import UIKit

func getRootViewController() -> UIViewController? {
    return UIApplication.shared.windows.first?.rootViewController
}
#elseif canImport(AppKit)
import AppKit

func getRootViewController() -> NSViewController? {
    return NSApplication.shared.windows.first?.contentViewController
}
#endif
