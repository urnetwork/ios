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
    
    init(api: SdkBringYourApi, logout: @escaping () -> Void) {
        _viewModel = StateObject.init(wrappedValue: ViewModel(
            api: api
        ))
        self.logout = logout
    }
    
    var body: some View {
        VStack {
            Text("Connect View!!")
            
            Spacer().frame(height: 32)
            
            Button(action: logout) {
                Text("Logout")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(red: 0.06, green: 0.06, blue: 0.06))
    }
}

#Preview {
    ConnectView(
        api: SdkBringYourApi(),
        logout: {}
    )
}
