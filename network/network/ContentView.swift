//
//  ContentView.swift
//  network
//
//  Created by brien on 11/18/24.
//

import SwiftUI
import URnetworkSdk
import GoogleSignIn

struct ContentView: View {
    
    var api: SdkBringYourApi?
    
    @StateObject var viewModel = ViewModel()
    @StateObject var deviceManager = DeviceManager()
    @StateObject private var snackbarManager = UrSnackbarManager()
    
    @State private var opacity: Double = 0.0
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @State var welcomeAnimationComplete: Bool = true
    
    var body: some View {
        ZStack {
            
            if let api = deviceManager.api {
                
                switch viewModel.contentViewPath {
                    
                case .uninitialized:
                    ProgressView("Loading...")
                case .authenticate:
                    LoginNavigationView(
                        api: api,
                        handleSuccess: handleSuccessWithJwt
                    )
                    .opacity(opacity)

                case .main:
                    if let device = deviceManager.device {
                        MainView(
                            api: api,
                            device: device,
                            logout: deviceManager.logout,
                            welcomeAnimationComplete: $welcomeAnimationComplete
                        )
                        .opacity(opacity)

                    } else {
                        ProgressView("Loading...")
                    }
                    
                }
                
            } else {
                // loading indicator?
                ProgressView("Loading...")
            }
            
            UrSnackBar(message: snackbarManager.message, isVisible: snackbarManager.isVisible)
                .padding(.bottom, 50)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environmentObject(deviceManager)
        .background(themeManager.currentTheme.backgroundColor)
        .environmentObject(snackbarManager)
        .onReceive(deviceManager.$device) { device in
            
            if deviceManager.deviceInitialized {
                
                if device != nil {
                    welcomeAnimationComplete = false
                }
                
                updatePath()
            }
            
        }
        .onReceive(deviceManager.$deviceInitialized) { isInitialized in
            print("is initialized is \(isInitialized)")
            
            if isInitialized {
                
                updatePath()
                
            }
            
        }
        
    }
    
    private func updatePath() {
        
        withAnimation {
            opacity = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            viewModel.updatePath(deviceManager.device)
            
            withAnimation {
                opacity = 1.0
            }
            
        }
    }
    
    private func handleSuccessWithJwt(_ jwt: String) async {
        let result = await deviceManager.authenticateNetworkClient(jwt)
        
        if case .failure(let error) = result {
            print("[ContentView] handleSuccessWithJwt: \(error.localizedDescription)")
            
            snackbarManager.showSnackbar(message: "There was an error creating your network. Please try again later.")
            
            return
        }
        
        // TODO: fade out login flow
        // TODO: create navigation view model and switch to main app instead of checking deviceManager.device
        
    }
    
}
//
//#Preview {
//    ContentView(
//        api: SdkBringYourApi()
//    )
//        .environmentObject(ThemeManager.shared)
//}
