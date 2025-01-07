//
//  View.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/07.
//

import Foundation
import SwiftUI
import UIKit

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

