//
//  LoginInitialView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/20.
//

import SwiftUI

struct LoginInitialView: View {
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .applySystemBackground()
    }
}

#Preview {
    LoginInitialView()
        .environmentObject(ThemeManager.shared)
}
