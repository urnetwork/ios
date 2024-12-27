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
            
            Image("GlobeConnector")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 256, height: 256)
         
            Canvas { context, size in
                
                for (id, point) in viewModel.animatedPoints {
                    
                    let centerX = CGFloat(point.x) * viewModel.maxPointSize + viewModel.maxPointSize / 2
                    let centerY = CGFloat(point.y) * viewModel.maxPointSize + viewModel.maxPointSize / 2
                    
                    // keep point centered
                    let rect = CGRect(
                        x: centerX - point.currentSize / 2,
                        y: centerY - point.currentSize / 2,
                        width: point.currentSize,
                        height: point.currentSize
                    )
                    
                    context.fill(Path(ellipseIn: rect), with: .color(viewModel.getStateColor(id)))
                }
                
            }
            .frame(width: viewModel.canvasWidth, height: viewModel.canvasWidth)
            .onChange(of: gridPoints) { newPoints in
                if gridWidth > 0 {
                    viewModel.updateGridPoints(newPoints, gridWidth: gridWidth)
                }
            }
            .onChange(of: gridWidth) { newWidth in
                if newWidth > 0 && !gridPoints.isEmpty {
                    viewModel.updateGridPoints(gridPoints, gridWidth: newWidth)
                }
            }
            
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
