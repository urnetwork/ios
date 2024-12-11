//
//  UrBottomSheet.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import SwiftUI

struct UrBottomSheet<Content: View>: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isExpanded: Bool
    let content: () -> Content
    
    private let minimumHeight: CGFloat = 100
    @State private var offset: CGFloat = 0
    @GestureState private var translation: CGFloat = 0
    @State private var lastDragPosition: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let maxHeight = min(geometry.size.height * 0.8,
                              geometry.frame(in: .global).height - geometry.safeAreaInsets.top)
            
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)
                    
                    content()
                }
                .frame(width: geometry.size.width, height: maxHeight)
                .background(
                    RoundedCorner(radius: 12, corners: [.topLeft, .topRight])
                        .fill(themeManager.currentTheme.backgroundColor)
                )
                .shadow(color: themeManager.currentTheme.borderBaseColor, radius: 0, x: 0, y: -1)
                .offset(y: geometry.size.height - minimumHeight + offset + translation)
                .gesture(
                    DragGesture()
                        .updating($translation) { value, state, _ in
                            state = value.translation.height
                        }
                        .onChanged { value in
                            let delta = value.translation.height - lastDragPosition
                            offset += delta
                            lastDragPosition = value.translation.height
                        }
                        .onEnded { value in
                            lastDragPosition = 0
                            let velocity = value.predictedEndLocation.y - value.location.y
                            
                            withAnimation(.spring()) {
                                if offset < -maxHeight/3 || velocity < -300 {
                                    offset = -maxHeight + minimumHeight
                                    isExpanded = true
                                } else {
                                    offset = 0
                                    isExpanded = false
                                }
                            }
                        }
                )
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

//#Preview {
//    UrBottomSheet()
//}
