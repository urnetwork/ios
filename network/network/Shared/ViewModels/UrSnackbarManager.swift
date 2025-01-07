//
//  UrSnackbarManager.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/07.
//

import Foundation

class UrSnackbarManager: ObservableObject {
    
    @Published private(set) var message: String = ""
    @Published private(set) var isVisible: Bool = false

    func showSnackbar(message: String) {
        self.message = message
        self.isVisible = true

        // Hide the snackbar after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isVisible = false
        }
    }
    
}
