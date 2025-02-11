// swift-tools-version:5.3
import PackageDescription

// see https://developer.apple.com/documentation/xcode/distributing-binary-frameworks-as-swift-packages
let package = Package(
	name: "URnetworkSdk",
	products: [
		.library(
			name: "URnetworkSdk",
			targets: ["URnetworkSdkBinary"]
		),
	],
	targets: [
		.binaryTarget(
			name: "URnetworkSdkBinary",
			path: "../../../sdk/build/apple/URnetworkSdk.xcframework"
		),
		.testTarget(
			name: "URnetworkSdkTests",
			dependencies: ["URnetworkSdkBinary"]
		),
	]
)
