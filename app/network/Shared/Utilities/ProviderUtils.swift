//
//  ProviderUtils.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/12.
//

import Foundation
import URnetworkSdk
import SwiftUI

func getProviderColor(_ provider: SdkConnectLocation) -> Color {
    return Color(hex: SdkGetColorHex(
        provider.locationType == SdkLocationTypeCountry ? provider.countryCode : provider.connectLocationId?.string()
    ))
}
