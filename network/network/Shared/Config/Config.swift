//
//  Config.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/06.
//

import Foundation

struct Config {
    static var googleClientID: String {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            fatalError("GIDClientID not found in Info.plist")
        }
        return clientID
    }
}
