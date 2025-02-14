//
//  ReferralShareLink.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/04.
//

import SwiftUI
import URnetworkSdk

struct ReferralShareLink<Content: View>: View {
    
    // @StateObject var viewModel: ViewModel
    @ObservedObject var referralLinkViewModel: ReferralLinkViewModel
    
    let content: () -> Content
    
    init(referralLinkViewModel: ReferralLinkViewModel, content: @escaping () -> Content) {
        self.content = content
        self.referralLinkViewModel = referralLinkViewModel
    }
    
    var body: some View {
        ShareLink(item: URL(string: "https://ur.io/app?bonus=\(referralLinkViewModel.referralCode ?? "")")!, subject: Text("URnetwork Referral Code"), message: Text("All the content in the world from URnetwork")) {
            content()
        }
        .disabled(referralLinkViewModel.isLoading)
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

//#Preview {
//    ReferralShareLink(
//        api: SdkApi(),
//        referralLinkViewModel: ReferralLinkViewModel(api: SdkApi())
//    ) {
//        Label("Share URnetwork", systemImage: "square.and.arrow.up")
//    }
//}
