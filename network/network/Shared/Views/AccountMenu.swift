//
//  AccountActions.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/29.
//

import SwiftUI
import URnetworkSdk

struct AccountMenu: View {
    
    var isGuest: Bool
    var logout: () -> Void
    var api: SdkApi
    
    var body: some View {
    
        Menu {
            
            if isGuest {
                Button(action: {}) {
                    Label("Create account", systemImage: "person.crop.circle.badge.plus")
                }
            }
            
            Button(action: {
                logout()
            }) {
                Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
            }
            
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
        api: SdkApi()
    )
}
