//
//  ConnectView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import SwiftUI
import URnetworkSdk

struct ConnectView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var deviceManager: DeviceManager
    @EnvironmentObject var snackbarManager: UrSnackbarManager
    @Environment(\.requestReview) private var requestReview
    
    @StateObject private var viewModel: ViewModel
    
    var logout: () -> Void
    var api: SdkApi
    @ObservedObject var providerListSheetViewModel: ProviderListSheetViewModel
    
    init(
        api: SdkApi,
        logout: @escaping () -> Void,
        device: SdkDeviceRemote?,
        connectViewController: SdkConnectViewController?,
        providerListSheetViewModel: ProviderListSheetViewModel
    ) {
        _viewModel = StateObject.init(wrappedValue: ViewModel(
            api: api,
            device: device,
            connectViewController: connectViewController
        ))
        self.logout = logout
        self.api = api
        self.providerListSheetViewModel = providerListSheetViewModel
        
        // adds clear button to search providers text field
        #if os(iOS)
        UITextField.appearance().clearButtonMode = .whileEditing
        #endif
    }
    
    var body: some View {
        
        let isGuest = deviceManager.parsedJwt?.guestMode ?? true
        
        VStack {
            
//            HStack {
//                Spacer()
//                AccountMenu(
//                    isGuest: isGuest,
//                    logout: logout,
//                    api: api,
//                    isPresentedCreateAccount: $viewModel.isPresentedCreateAccount
//                )
//            }
//            .frame(height: 32)
            
            Spacer()
            
            ConnectButtonView(
                gridPoints:
                    viewModel.gridPoints,
                gridWidth: viewModel.gridWidth,
                connectionStatus: viewModel.connectionStatus,
                windowCurrentSize: viewModel.windowCurrentSize,
                connect: viewModel.connect,
                disconnect: viewModel.disconnect
            )
            
            Spacer()
            
            Button(action: {
                providerListSheetViewModel.isPresented = true
            }) {

                HStack {
                    
                    if let selectedProvider = viewModel.selectedProvider, selectedProvider.connectLocationId?.bestAvailable != true {
   
                        Image("ur.symbols.tab.connect")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(viewModel.getProviderColor(selectedProvider))
                        
                        Spacer().frame(width: 16)
                        
                        VStack(alignment: .leading) {
                            Text(selectedProvider.name)
                                .font(themeManager.currentTheme.bodyFont)
                                .foregroundColor(themeManager.currentTheme.textColor)
                            
                            if selectedProvider.providerCount > 0 {
            
                                Text("\(selectedProvider.providerCount) providers")
                                    .font(themeManager.currentTheme.secondaryBodyFont)
                                    .foregroundColor(themeManager.currentTheme.textMutedColor)
                            }
            
                            
                        }
                    } else {
           
                        Image("ur.symbols.tab.connect")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.urCoral)
                        
                        Spacer().frame(width: 16)
                        
                        VStack(alignment: .leading) {
                            Text("Best available provider")
                                .font(themeManager.currentTheme.bodyFont)
                                .foregroundColor(themeManager.currentTheme.textColor)
                        }
                        
                    }
                    
                    Spacer().frame(width: 8)
                    
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                
            }
            .background(themeManager.currentTheme.tintedBackgroundBase)
            .clipShape(.capsule)
            
        }
        .onAppear {
            
            /**
             * Create callback function for prompting rating
             */
            viewModel.requestReview = {
                Task {
                    
                    if let device = deviceManager.device {
                        
                        if device.getShouldShowRatingDialog() {
                            device.setCanShowRatingDialog(false)
                            try await Task.sleep(for: .seconds(2))
                            requestReview()
                        }
                        
                    }
                    
                }
            }
            
        }
        .padding()
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $providerListSheetViewModel.isPresented) {
            
//            ProvidersListSheet(
//                viewModel: viewModel,
//                setIsPresented: { isPresented in
//                    providerListSheetViewModel.isPresented = isPresented
//                }
//            )
            
            ProviderListSheetView(
                selectedProvider: viewModel.selectedProvider,
                connect: { provider in
                    viewModel.connect(provider)
                    providerListSheetViewModel.isPresented = false
                },
                connectBestAvailable: {
                    viewModel.connectBestAvailable()
                    providerListSheetViewModel.isPresented = false
                },
                providerCountries: viewModel.providerCountries,
                providerPromoted: viewModel.providerPromoted,
                providerDevices: viewModel.providerDevices,
                providerRegions: viewModel.providerRegions,
                providerCities: viewModel.providerCities,
                providerBestSearchMatches: viewModel.providerBestSearchMatches,
                setIsPresented: { isPresented in
                    providerListSheetViewModel.isPresented = isPresented
                },
                searchText: $viewModel.searchQuery
            )
            
            
        }
        
        #if os(iOS)
        // upgrade guest account flow
        .fullScreenCover(isPresented: $viewModel.isPresentedCreateAccount) {
            LoginNavigationView(
                api: api,
                cancel: {
                    viewModel.isPresentedCreateAccount = false
                },
                
                handleSuccess: { jwt in
                    Task {
                        await handleSuccessWithJwt(jwt)
                        viewModel.isPresentedCreateAccount = false
                    }
                }
            )
        }
        #endif
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

#if os(iOS)
struct ProvidersListSheet: View {
    
    var viewModel: ConnectView.ViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
         NavigationStack {
            
            ProviderListSheetView(
                selectedProvider: viewModel.selectedProvider,
                connect: { provider in
                    viewModel.connect(provider)
                    providerListSheetViewModel.isPresented = false
                },
                connectBestAvailable: {
                    viewModel.connectBestAvailable()
                    providerListSheetViewModel.isPresented = false
                },
                providerCountries: viewModel.providerCountries,
                providerPromoted: viewModel.providerPromoted,
                providerDevices: viewModel.providerDevices,
                providerRegions: viewModel.providerRegions,
                providerCities: viewModel.providerCities,
                providerBestSearchMatches: viewModel.providerBestSearchMatches
            )
            .navigationBarTitleDisplayMode(.inline)

            
            .searchable(
                text: $viewModel.searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search providers"
            )
            .toolbar {

                ToolbarItem(placement: .principal) {
                    Text("Available providers")
                        .font(themeManager.currentTheme.toolbarTitleFont).fontWeight(.bold)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        providerListSheetViewModel.isPresented = false
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .refreshable {
                let _ = await viewModel.filterLocations(viewModel.searchQuery)
            }
            .onAppear {
                Task {
                    let _ = await viewModel.filterLocations(viewModel.searchQuery)
                }
            }
            
         }
        .background(themeManager.currentTheme.backgroundColor)
    }
}
#elseif os(macOS)

struct ProvidersListSheet: View {
    
    @ObservedObject var viewModel: ConnectView.ViewModel
    var setIsPresented: (Bool) -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
         NavigationStack {
            
            ProviderListSheetView(
                selectedProvider: viewModel.selectedProvider,
                connect: { provider in
                    viewModel.connect(provider)
                    setIsPresented(false)
                    // providerListSheetViewModel.isPresented = false
                },
                connectBestAvailable: {
                    viewModel.connectBestAvailable()
                    setIsPresented(false)
                    // providerListSheetViewModel.isPresented = false
                },
                providerCountries: viewModel.providerCountries,
                providerPromoted: viewModel.providerPromoted,
                providerDevices: viewModel.providerDevices,
                providerRegions: viewModel.providerRegions,
                providerCities: viewModel.providerCities,
                providerBestSearchMatches: viewModel.providerBestSearchMatches,
                setIsPresented: {_ in },
                searchText: $viewModel.searchQuery
            )
            // .navigationBarTitleDisplayMode(.inline)

//            .searchable(
//                text: $viewModel.searchQuery,
//                prompt: "Search providers"
//            )
        
            .navigationTitle("Available providers")
            // .navigationBarTitleDisplayMode(.inline)
            .toolbar {

//                ToolbarItem(placement: .principal) {
//                    Text("Available providers")
//                        .font(themeManager.currentTheme.toolbarTitleFont).fontWeight(.bold)
//                }

                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        setIsPresented(false)
                        // providerListSheetViewModel.isPresented = false
                    }) {
                        Image(systemName: "xmark")
                    }
                }
                
            }
            .refreshable {
                let _ = await viewModel.filterLocations(viewModel.searchQuery)
            }
            .onAppear {
                Task {
                    let _ = await viewModel.filterLocations(viewModel.searchQuery)
                }
            }

            
         }
        .background(themeManager.currentTheme.backgroundColor)
    }
    
}

#endif

#Preview {
    ConnectView(
        api: SdkApi(),
        logout: {},
        device: nil,
        connectViewController: nil,
        providerListSheetViewModel: ProviderListSheetViewModel()
    )
}
