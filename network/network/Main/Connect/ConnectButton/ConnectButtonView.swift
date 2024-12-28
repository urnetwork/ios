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
    
    
    @StateObject private var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        
        ZStack {
            
//            ConnectCanvasConnectingStateView(gridPoints: gridPoints, gridWidth: gridWidth)
            
            ConnectCanvasDisconnectedStateView()
            
            Image("GlobeMask")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 256, height: 256)
            
        }
        .background(themeManager.currentTheme.tintedBackgroundBase)
//        .onDisappear {
//            viewModel.stopAnimations()
//        }
    }
}

#Preview {
    ConnectButtonView(
        gridPoints: [:],
        gridWidth: 16
    )
}
