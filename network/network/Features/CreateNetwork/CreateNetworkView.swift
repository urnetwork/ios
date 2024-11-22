//
//  CreateNetworkView.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/11/21.
//

import SwiftUI

struct CreateNetworkView: View {
    
    var userAuth: String
    
    var body: some View {
        VStack {
            Text("Create Network")
                .foregroundColor(.urWhite)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .applySystemBackground()
    }
}

#Preview {
    CreateNetworkView(
        userAuth: "hello@ur.io"
    )
}
