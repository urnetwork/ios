//
//  AccountActions.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/29.
//

import SwiftUI
import URnetworkSdk

struct AccountMenu: View {
    
    // TODO: handle isGuest
    var isGuest: Bool
    var logout: () -> Void
    var api: SdkBringYourApi
    
    var body: some View {
    
        Menu {
            
            if isGuest {
                Button(action: {}) {
                    Label("Create account", systemImage: "person.crop.circle.badge.plus")
                }
            } else {
                Button(action: {
                    logout()
                }) {
                    Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
            
//            ShareLink(item: URL(string: "https://ur.io/app?bonus=\(referralCodeViewModel.referralCode ?? "")")!, subject: Text("URnetwork Referral Code"), message: Text("All the content in the world from URnetwork")) {
//                Label("Share URnetwork", systemImage: "square.and.arrow.up")
//            }
            
            ReferralShareLink(api: api) {
                Label("Share URnetwork", systemImage: "square.and.arrow.up")
            }
            
        } label: {
            Image("AccountMenuLabelImage")
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
        }
        

    }
}

#Preview {
    AccountMenu(
        isGuest: false,
        logout: {},
        api: SdkBringYourApi()
    )
}
