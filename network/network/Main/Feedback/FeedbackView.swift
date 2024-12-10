//
//  FeedbackView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/10.
//

import SwiftUI
import URnetworkSdk

struct FeedbackView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(api: SdkBringYourApi) {
        _viewModel = StateObject.init(wrappedValue: ViewModel(
            api: api
        ))
    }
    
    var body: some View {
        Text("Support View")
    }
}

#Preview {
    FeedbackView(
        api: SdkBringYourApi()
    )
}
