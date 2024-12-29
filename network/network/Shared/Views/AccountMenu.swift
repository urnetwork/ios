//
//  AccountActions.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/29.
//

import SwiftUI

struct AccountMenu: View {
    
    // TODO: handle isGuest
    var isGuest: Bool
    
    var logout: () -> Void
    
    var body: some View {
    
        Menu {
            
            if isGuest {
                Button(action: {}) {
                    Label("Create account", systemImage: "person.crop.circle.badge.plus")
                }
            } else {
                Button(action: {}) {
                    Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
            
            Button(action: {}) {
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
        logout: {}
    )
}
