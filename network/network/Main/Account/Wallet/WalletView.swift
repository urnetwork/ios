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
    
    var back: () -> Void
    
    init(api: SdkBringYourApi, back: @escaping () -> Void) {
        _viewModel = StateObject.init(wrappedValue: ViewModel(
            api: api
        ))
        self.back = back
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    WalletView(
        api: SdkBringYourApi(),
        back: {}
    )
}
