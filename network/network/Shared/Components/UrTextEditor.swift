//
//  UrTextEditor.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/17.
//

import SwiftUI

struct UrTextEditor: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @Binding var text: String
    var height: CGFloat = 100
    var enabled: Bool = true
    
    var body: some View {
        TextEditor(
            text: $text
        )
        .padding(.horizontal, 4)
        .frame(height: height)
        .disabled(!enabled)
        .scrollContentBackground(.hidden) // otherwise background color doesn't work
        .background(themeManager.currentTheme.tintedBackgroundBase)
        .cornerRadius(8)
        .foregroundColor(themeManager.currentTheme.textColor)
    }
}

#Preview {
    UrTextEditor(
        text: .constant("hello world")
    )
        .environmentObject(ThemeManager.shared)
}
