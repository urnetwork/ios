//
//  ConnectButtonConnectingStateViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/28.
//

import Foundation
import URnetworkSdk
import SwiftUI

extension ConnectCanvasConnectingStateView {
    
    enum GridPointState: String {
        case inEvaluation = "InEvaluation"
        case evaluationFailed = "EvaluationFailed"
        case notAdded = "NotAdded"
        case added = "Added"
        case removed = "Removed"
    }
    
    struct AnimatedGridPoint {
        var currentState: GridPointState
        var previousState: GridPointState?
        var stateAnimationProgress: Double = 1.0
        var sizeAnimationProgress: Double = 1.0
        var currentSize: CGFloat
        var targetSize: CGFloat
        var x: Int32
        var y: Int32
        
        var isAnimating: Bool {
            return stateAnimationProgress < 1.0 || sizeAnimationProgress < 1.0
        }
    }
    
    @MainActor
    class ViewModel: ObservableObject {
        
        @Published var animatedPoints: [String: AnimatedGridPoint] = [:]
        private var animationTimer: Timer?
        let canvasWidth: CGFloat = 256
        @Published var maxPointSize: CGFloat = 0
        
        func updateGridPoints(_ points: [SdkId: SdkProviderGridPoint], gridWidth: Int32) {
            
            if gridWidth > 0 {
                
                self.maxPointSize = canvasWidth / CGFloat(gridWidth)
                    
                var processedPoints = Set<String>()
                
                for (id, point) in points {
                    let idStr = id.idStr
                    processedPoints.insert(idStr)
                    
                    if let state = GridPointState(rawValue: point.state) {
                        if let existingPoint = animatedPoints[idStr] {
                            // update an existing point
                            if existingPoint.currentState != state {
                                var updatedPoint = existingPoint
                                updatedPoint.previousState = existingPoint.currentState
                                updatedPoint.currentState = state
                                updatedPoint.stateAnimationProgress = 0.0
                                animatedPoints[idStr] = updatedPoint
                            }
                        } else {
                            
                            // add a new point
                            animatedPoints[idStr] = AnimatedGridPoint(
                                currentState: state,
                                previousState: nil,
                                stateAnimationProgress: 0.0,
                                sizeAnimationProgress: 0.0,
                                currentSize: 0,
                                targetSize: maxPointSize,
                                x: point.x,
                                y: point.y
                            )
                        }
                    }
                }
                
                // Check for removed points
                let removedPoints = Set(animatedPoints.keys).subtracting(processedPoints)
                
                for id in removedPoints {
                    if var point = animatedPoints[id] {
                        point.previousState = point.currentState
                        point.currentState = .removed
                        point.stateAnimationProgress = 0.0
                        animatedPoints[id] = point
                    }
                }
                
                startAnimationTimer()
                
            } else {
                print("updateGridPoints: grid width is zero")
            }
            
                
        }
        
        private func startAnimationTimer() {
            animationTimer?.invalidate()
            animationTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    await self?.updateAnimations()
                }
            }
        }
        
        func stopAnimations() {
            animationTimer?.invalidate()
            animationTimer = nil
        }
        
        private func easeInOut(_ x: Double) -> Double {
            return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
        }
        
        private func updateAnimations() async {
            let animationStep: Double = 0.05
            
            for (id, point) in animatedPoints {
                var updatedPoint = point
                
                // size animation
                if updatedPoint.sizeAnimationProgress < 1.0 {
                    // update progress
                    updatedPoint.sizeAnimationProgress = min(1.0, point.sizeAnimationProgress + animationStep)
                    let easedProgress = easeInOut(updatedPoint.sizeAnimationProgress)
                    updatedPoint.currentSize = updatedPoint.targetSize * easedProgress
                }
                
                // color animation
                if updatedPoint.stateAnimationProgress < 1.0 {
                    updatedPoint.stateAnimationProgress = min(1.0, point.stateAnimationProgress + animationStep)
                }
                
                animatedPoints[id] = updatedPoint
            }
            
            // Ccean up when both animations complete
            animatedPoints = animatedPoints.filter { id, point in
                let shouldKeep = !(point.currentState == .removed &&
                                 point.stateAnimationProgress >= 1.0 &&
                                 point.sizeAnimationProgress >= 1.0)
                if !shouldKeep {
                    print("Removing point \(id)")
                }
                return shouldKeep
            }
            
            // keep timer running if any animation is still in progress
            if animatedPoints.values.allSatisfy({ !$0.isAnimating }) {
                print("Stopping animation timer")
                animationTimer?.invalidate()
                animationTimer = nil
            }
        }
        
        func getStateColor(_ id: String) -> Color {
            guard let point = animatedPoints[id] else {
                return .gray
            }
            
            let currentColor = colorForState(point.currentState)
            
            guard let previousState = point.previousState,
                  point.stateAnimationProgress < 1.0 else {
                return currentColor
            }
            
            let previousColor = colorForState(previousState)
            return blend(from: previousColor,
                        to: currentColor,
                        progress: point.stateAnimationProgress)
        }

        private func blend(from: Color, to: Color, progress: Double) -> Color {
            let fromComponents = getColorComponents(from: from)
            let toComponents = getColorComponents(from: to)
                  
            let r = fromComponents[0] + (toComponents[0] - fromComponents[0]) * progress
            let g = fromComponents[1] + (toComponents[1] - fromComponents[1]) * progress
            let b = fromComponents[2] + (toComponents[2] - fromComponents[2]) * progress
            let a = fromComponents[3] + (toComponents[3] - fromComponents[3]) * progress
            
            let color = getColor(r: r, g: g, b: b, a: a)
            return color
        }
        
        func getColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> Color {
            #if canImport(UIKit)
            return Color(uiColor: UIColor(red: r, green: g, blue: b, alpha: a))
            #elseif canImport(AppKit)
            return Color(nsColor: NSColor(red: r, green: g, blue: b, alpha: a))
            #endif
        }
        
        func getColorComponents(from color: Color) -> [CGFloat] {
            #if canImport(UIKit)
            let uiColor = UIColor(color)
            return uiColor.cgColor.components ?? [0, 0, 0, 0]
            #elseif canImport(AppKit)
            let nsColor = NSColor(color)
            let convertedColor = nsColor.usingColorSpace(.deviceRGB) ?? NSColor.black
            let components = convertedColor.cgColor.components ?? [0, 0, 0, 1]
            return components + Array(repeating: 0, count: max(0, 4 - components.count))
            #endif
        }
        
//        func getColorComponents(from color: Any) -> [CGFloat] {
//            #if canImport(UIKit)
//            let uiColor = color as? UIColor ?? UIColor.black
//            return uiColor.cgColor.components ?? [0, 0, 0, 0]
//            #elseif canImport(AppKit)
//            let nsColor = color as? NSColor ?? NSColor.black
//            let convertedColor = nsColor.usingColorSpace(.deviceRGB) ?? NSColor.black
//            return convertedColor.cgColor.components ?? [0, 0, 0, 0]
////            let nsColor = color as? NSColor ?? NSColor.black
////            return nsColor.cgColor.components ?? [0, 0, 0, 0]
//            #endif
//        }
        
        private func colorForState(_ state: GridPointState) -> Color {
            switch state {
            case .inEvaluation: return .urLightYellow
            case .evaluationFailed: return .urCoral
            case .notAdded: return .urCoral
            case .added: return .urGreen
            case .removed: return .urBlack.opacity(0)
            }
        }
        
    }
}
