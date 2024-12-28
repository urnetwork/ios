//
//  ConnectButtonView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/27.
//

import SwiftUI
import URnetworkSdk

struct ConnectButtonView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var gridPoints: [SdkId: SdkProviderGridPoint]
    var gridWidth: Int32
    var connectionStatus: ConnectionStatus?
    
    let canvasWidth: CGFloat = 256
    
    
    @StateObject private var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        
        ZStack {
            
            
            
            /**
             * Disconnected
             */
            ConnectCanvasDisconnectedStateView().opacity(connectionStatus == .disconnected ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: connectionStatus)
            
            /**
             * Connecting grid
             */
            ConnectCanvasConnectingStateView(gridPoints: gridPoints, gridWidth: gridWidth)
                .opacity((connectionStatus == .connecting || connectionStatus == .destinationSet)
                    ? 1
                    : 0)
                .animation(.easeInOut(duration: 0.5), value: connectionStatus)
            
            /**
             * Connected
             */
            ConnectCanvasConnectedStateView(
                canvasWidth: canvasWidth,
                isActive: connectionStatus == .connected
            )
        
            Image("GlobeMask")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: canvasWidth, height: canvasWidth)
            
        }
        .background(themeManager.currentTheme.tintedBackgroundBase)
    }
}

#Preview {
    ConnectButtonView(
        gridPoints: [:],
        gridWidth: 16,
        connectionStatus: .disconnected
    )
}
