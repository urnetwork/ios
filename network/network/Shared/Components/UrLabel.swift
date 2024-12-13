//
//  UrLabel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/13.
//

import SwiftUI

struct UrLabel: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var text: LocalizedStringKey
    var foregroundColor: Color? = nil
    
    var body: some View {
        Text(text)
            .font(themeManager.currentTheme.secondaryBodyFont)
            .foregroundColor(foregroundColor ?? themeManager.currentTheme.textMutedColor)
    }
}

#Preview {
    UrLabel(
        text: "Notifications"
    )
    .environmentObject(ThemeManager.shared)
}
