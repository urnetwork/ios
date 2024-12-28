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
    var windowCurrentSize: Int32
    
    let canvasWidth: CGFloat = 256
    
    var statusMsgIconColor: Color {
        
        switch connectionStatus {
        case .disconnected: return .urElectricBlue
        case .connecting: return .urYellow
        case .destinationSet: return .urYellow
        case .connected: return .urGreen
        case .none: return .urElectricBlue
        }
        
    }
    
    var statusMsg: String {
        switch connectionStatus {
        case .disconnected: return "Ready to connect"
        case .connecting, .destinationSet: return "Connecting to providers"
        case .connected: return "Connected to \(windowCurrentSize) providers"
        case .none: return ""
        }
    }
    
    @StateObject private var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        
        VStack {
        
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
            
            Spacer().frame(height: 32)
            
            HStack {
                
                ZStack {
                    Image("GlobeMask")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                }
                .background(statusMsgIconColor)
                
                Spacer().frame(width: 8)
                
                Text(statusMsg)
                    .font(themeManager.currentTheme.bodyFont)
                    .foregroundColor(themeManager.currentTheme.textColor)
                
            }
            
        }
        
    }
}

#Preview {
    ConnectButtonView(
        gridPoints: [:],
        gridWidth: 16,
        connectionStatus: .disconnected,
        windowCurrentSize: 12
    )
}
