//
//  UIApplication.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/14.
//

import Foundation
import SwiftUI

extension UIApplication {
    func endEditing(_ force: Bool) {
        guard let windowScene = connectedScenes.first as? UIWindowScene else { return }
        windowScene.windows
            .filter { $0.isKeyWindow }
            .first?
            .endEditing(force)
    }
}
