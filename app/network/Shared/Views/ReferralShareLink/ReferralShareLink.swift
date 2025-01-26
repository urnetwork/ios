//
//  ReferralShareLink.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/04.
//

import SwiftUI
import URnetworkSdk

struct ReferralShareLink<Content: View>: View {
    
    @StateObject var viewModel: ViewModel
    
    let content: () -> Content
    
    init(api: SdkApi, content: @escaping () -> Content) {
        _viewModel = StateObject(wrappedValue: ViewModel(api: api))
        self.content = content
    }
    
    var body: some View {
        ShareLink(item: URL(string: "https://ur.io/app?bonus=\(viewModel.referralCode ?? "")")!, subject: Text("URnetwork Referral Code"), message: Text("All the content in the world from URnetwork")) {
            content()
        }
        .disabled(viewModel.isLoading)
    }
}

#Preview {
    ReferralShareLink(
        api: SdkApi()
    ) {
        Label("Share URnetwork", systemImage: "square.and.arrow.up")
    }
}
