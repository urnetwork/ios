//
//  ContentView.swift
//  network
//
//  Created by brien on 11/18/24.
//

import SwiftUI
import URnetworkSdk
import GoogleSignIn

// TODO: either deprecate or move content of NetworkApp into this component

struct ContentView: View {
    
    var api: SdkBringYourApi?
    
    @StateObject var viewModel = ViewModel()
    @StateObject var deviceManager = DeviceManager()
    @StateObject private var snackbarManager = UrSnackbarManager()
    
    @State private var opacity: Double = 0.0
    
    @EnvironmentObject var themeManager: ThemeManager
    
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
//                    .onAppear {
//                        withAnimation {
//                            opacity = 1.0
//                        }
//                    }
                case .main:
                    if let device = deviceManager.device {
//                        MainTabView(
//                            api: api,
//                            device: device,
//                            logout: deviceManager.logout,
//                            provideWhileDisconnected: $deviceManager.provideWhileDisconnected
//                        )
                        MainView(
                            api: api,
                            device: device,
                            logout: deviceManager.logout
                        )
                        .opacity(opacity)
//                        .onAppear {
//                            withAnimation {
//                                opacity = 1.0
//                            }
//                        }
                    } else {
                        ProgressView("Loading...")
                    }
                    
                }
                
//                if let device = deviceManager.device {
//                    
//                    MainTabView(
//                        api: api,
//                        device: device,
//                        logout: deviceManager.logout,
//                        provideWhileDisconnected: $deviceManager.provideWhileDisconnected
//                    )
//                    
//                } else {
//                    
//                    LoginNavigationView(
//                        api: api,
//                        handleSuccess: handleSuccessWithJwt
//                    )
//                    
//                }
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
//        .environmentObject(ThemeManager.shared)
        .environmentObject(snackbarManager)
        .onReceive(deviceManager.$device) { device in
            
            withAnimation {
                opacity = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                viewModel.updatePath(device)
                
                withAnimation {
                    opacity = 1.0
                }
                
            }
            
        }
//        .onOpenURL { url in
//            GIDSignIn.sharedInstance.handle(url)
//        }
        
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
