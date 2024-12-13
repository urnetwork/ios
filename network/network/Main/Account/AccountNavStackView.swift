//
//  AccountView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import SwiftUI
import URnetworkSdk

struct AccountNavStackView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel: ViewModel = ViewModel()
    
    init(api: SdkBringYourApi) {
//        _viewModel = StateObject.init(wrappedValue: ViewModel(
//            api: api
//        ))
    }
    
    var body: some View {
        NavigationStack() {
            AccountView()
        }
    }
}

#Preview {
    AccountNavStackView(
        api: SdkBringYourApi()
    )
    .environmentObject(ThemeManager.shared)
}
