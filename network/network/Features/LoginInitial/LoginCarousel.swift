//
//  LoginCarousel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/27.
//

import SwiftUI
import Combine

struct LoginCarousel: View {
    
    private let images = ["LoginCarousel1", "LoginCarousel2", "LoginCarousel3"]
    @State private var currentOpacity = 1.0
    @State private var nextOpacity = 0.0
    @State private var currentIndex = 0
    @State private var nextIndex = 1
    @State private var cancellables = Set<AnyCancellable>()
    
    
    var body: some View {
        
        ZStack {
            
            // Current Image
            Image(images[currentIndex])
                .resizable()
                .scaledToFill()
                .frame(width: 256, height: 256)
                .opacity(currentOpacity)
            
            // Next Image
            Image(images[nextIndex])
                .resizable()
                .scaledToFill()
                .frame(width: 256, height: 256)
                .opacity(nextOpacity)
            
            Image("GlobeMask")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 256, height: 256)
            
        }
        .onAppear {
            startCarousel()
        }
        .clipped()
    }
    
    private func startCarousel() {
        Timer.publish(every: 4, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                // Cross-fade animation
                withAnimation(.easeInOut(duration: 2)) {
                    currentOpacity = 0
                    nextOpacity = 1
                }
                
                // Update indices after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    currentIndex = nextIndex
                    nextIndex = (nextIndex + 1) % images.count
                    currentOpacity = 1
                    nextOpacity = 0
                }
            }
            .store(in: &cancellables)
    }
}

#Preview {
    LoginCarousel()
}
