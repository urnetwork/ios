//
//  ThemeManager.swift
//  network
//
//  Created by Stuart Kuentzel on 2024/11/20.
//

import Foundation
import SwiftUI



final class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme = Theme.dark
    
    static let shared = ThemeManager()
    
    private init() {}
}

extension Theme {
    static let dark = Theme(
        systemBackground: Color("UrBlack"),

        accentColor: Color("UrElectricBlue"),
        dangerColor: Color("UrCoral"),
        
        textColor: Color.white,
        inverseTextColor: Color("UrBlack"),
        textMutedColor: Color(red: 0.6, green: 0.6, blue: 0.6),
        textFaintColor: Color(red: 0.35, green: 0.35, blue: 0.35),
        borderBaseColor: .white.opacity(0.12),
        
        titleFont: Font.custom("ABCGravity-Extended", size: 32),
        titleCondensedFont: Font.custom("ABCGravity-ExtraCondensed", size: 32),
        bodyFont: Font.custom("PP Neue Montreal", size: 16),
        secondaryBodyFont: Font.custom("PP Neue Montreal", size: 14)
    )
}
