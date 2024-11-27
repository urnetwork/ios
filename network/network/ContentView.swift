//
//  ContentView.swift
//  network
//
//  Created by brien on 11/18/24.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(
                "Hello, world!"
            )
            .foregroundStyle(.white)
            .font(themeManager.currentTheme.titleCondensedFont)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        // .background(Color("UrBlack"))
        .background(themeManager.currentTheme.backgroundColor)
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager.shared)
}
