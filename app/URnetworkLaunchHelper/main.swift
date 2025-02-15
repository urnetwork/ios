//
//  main.swift
//  URnetworkLaunchHelper
//
//  Created by Stuart Kuentzel on 2025/02/15.
//

import Foundation

// Get the path to the main app
let mainAppIdentifier = "network.ur"
let pathComponents = Bundle.main.bundlePath.split(separator: "/")
let mainAppPath = "/" + pathComponents.prefix(upTo: pathComponents.count - 4).joined(separator: "/")

// Launch the main app
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
process.arguments = [mainAppPath]

try? process.run()
