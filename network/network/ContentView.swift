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
    
    // @StateObject var viewModel = ViewModel()
    @StateObject var deviceManager = DeviceManager()
    @StateObject private var snackbarManager = UrSnackbarManager()
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            
            if let api = deviceManager.api {
                
                if let device = deviceManager.device {
                    
                    MainTabView(
                        api: api,
                        device: device,
                        logout: deviceManager.logout,
                        provideWhileDisconnected: $deviceManager.provideWhileDisconnected
                    )
                    
                } else {
                    
                    LoginNavigationView(
                        api: api,
                        handleSuccess: handleSuccessWithJwt
                        // authenticateNetworkClient: deviceManager.authenticateNetworkClient
                    )
                    
                }
            } else {
                // loading indicator?
                ProgressView("Loading...")
            }
            
            UrSnackBar(message: snackbarManager.message, isVisible: snackbarManager.isVisible)
                .padding(.bottom, 50)
            
        }
        .environmentObject(deviceManager)
//        .environmentObject(ThemeManager.shared)
        .environmentObject(snackbarManager)
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
