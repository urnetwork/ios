//
//  ConnectButtonDisconnectedStateView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/28.
//

import SwiftUI

struct ConnectCanvasDisconnectedStateView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject private var viewModel: ViewModel = ViewModel()
    
    @State private var pulseScale: CGFloat = 1
    @State private var pulseOpacity: Double = 1
    
    var body: some View {
        
        ZStack {
            Circle()
                .fill(Color.urElectricBlue)
                .frame(width: 56, height: 56)
                .scaleEffect(pulseScale)
                .opacity(pulseOpacity)
                .onAppear {
                    withAnimation(
                        Animation.easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        pulseScale = 1.5
                        pulseOpacity = 0
                    }
                }
            
            Circle()
                .stroke(Color.urElectricBlue, lineWidth: 4)
                .frame(width: 52, height: 52)
            
            Circle()
                .stroke(themeManager.currentTheme.tintedBackgroundBase, lineWidth: 2)
                .frame(width: 50, height: 50)
            
            Circle()
                .fill(Color.urElectricBlue)
                .frame(width: 48, height: 48)
        }
        .frame(width: 80, height: 80)
    }
}

#Preview {
    
    let themeManager = ThemeManager.shared
    
    VStack {
        ConnectCanvasDisconnectedStateView()
    }
    .environmentObject(themeManager)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(themeManager.currentTheme.backgroundColor)
}
