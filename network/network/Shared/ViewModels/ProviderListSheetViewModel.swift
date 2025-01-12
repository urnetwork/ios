//
//  ProviderListSheetViewModel.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2025/01/12.
//

import Foundation
import SwiftUI
import BottomSheet

class ProviderListSheetViewModel: ObservableObject {
    @Published var bottomSheetPosition: BottomSheetPosition = .absoluteBottom(164)
    let bottomSheetSwitchablePositions: [BottomSheetPosition] = [.absoluteBottom(164), .relativeTop(0.95)]
    
    func closeBottomSheet() {
        self.bottomSheetPosition = .absoluteBottom(164)
    }
}
