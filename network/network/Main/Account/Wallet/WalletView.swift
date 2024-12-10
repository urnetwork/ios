//
//  WalletView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import SwiftUI
import URnetworkSdk

struct WalletView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(api: SdkBringYourApi) {
        _viewModel = StateObject.init(wrappedValue: ViewModel(
            api: api
        ))
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    WalletView(
        api: SdkBringYourApi()
    )
}
