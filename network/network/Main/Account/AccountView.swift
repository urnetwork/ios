//
//  AccountView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import SwiftUI
import URnetworkSdk

struct AccountView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(api: SdkBringYourApi) {
        _viewModel = StateObject.init(wrappedValue: ViewModel(
            api: api
        ))
    }
    
    var body: some View {
        Text("Account View")
    }
}

#Preview {
    AccountView(
        api: SdkBringYourApi()
    )
}
