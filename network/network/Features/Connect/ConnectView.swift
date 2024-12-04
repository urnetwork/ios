//
//  ConnectView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import SwiftUI

struct ConnectView: View {
    
    var logout: () -> Void
    
    var body: some View {
        VStack {
            Text("Connect View!!")
            
            Spacer().frame(height: 32)
            
            Button(action: logout) {
                Text("Logout")
            }
        }
    }
}

#Preview {
    ConnectView(
        logout: {}
    )
}
