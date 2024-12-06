//
//  ViewControllerUtils.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/06.
//

import Foundation
import UIKit

func getRootViewController() -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
        return nil
    }
    return rootViewController
}

