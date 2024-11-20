//
//  PreviewBackgroundModifier.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/20.
//

import SwiftUI

struct SystemBackgroundModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager

    func body(content: Content) -> some View {
        content
            .background(themeManager.currentTheme.systemBackground.ignoresSafeArea())
    }
}

extension View {
    func applySystemBackground() -> some View {
        self.modifier(SystemBackgroundModifier())
    }
}
