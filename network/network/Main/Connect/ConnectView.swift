//
//  ConnectView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import SwiftUI
import URnetworkSdk

struct ConnectView: View {
    
    @StateObject private var viewModel: ViewModel
    
    var logout: () -> Void
    
    // let heights = stride(from: 0.3, through: 1.0, by: 0.1).map { PresentationDetent.fraction($0) }
    
    init(api: SdkBringYourApi, logout: @escaping () -> Void) {
        _viewModel = StateObject.init(wrappedValue: ViewModel(
            api: api
        ))
        self.logout = logout
    }
    
    var body: some View {
        
        ZStack {
            
            VStack {
                Text("Connect View!!")
                
                Spacer().frame(height: 32)
                
                Button(action: logout) {
                    Text("Logout")
                }
                
                Spacer().frame(height: 32)
                
                Button(action: {
                    viewModel.isPresentingProvidersList = true
                }) {
                    Text("Testing")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: $viewModel.isPresentingProvidersList) {
                Text("This app was brought to you by Hacking with Swift")
                    // .presentationDetents(Set(heights))
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled()
            }
            //        .background(Color(red: 0.06, green: 0.06, blue: 0.06))
            
            
            
            // Persistent Bottom Sheet
//            UrBottomSheet(isExpanded: $viewModel.isPresentingProvidersList) {
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("News & Updates")
//                            .font(.headline)
//                        
//                        // Example news items
//                        ForEach(0..<10) { index in
//                            VStack(alignment: .leading) {
//                                Text("News Item \(index + 1)")
//                                    .font(.subheadline)
//                                Text("Details about the news...")
//                                    .font(.caption)
//                            }
//                            .padding(.vertical, 4)
//                        }
//                    }
//                    .padding()
//                }
//            }
            
        }
    }
}

#Preview {
    ConnectView(
        api: SdkBringYourApi(),
        logout: {}
    )
}
