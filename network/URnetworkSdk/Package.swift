// swift-tools-version:5.3
import PackageDescription

let package = Package(
	name: "URnetworkSdk",
	products: [
		.library(
			name: "URnetworkSdk",
			targets: ["URnetworkSdk"]
		),
	],
	targets: [
		.binaryTarget(
			name: "URnetworkSdk",
			path: "../../../sdk/build/ios/URnetworkSdk.xcframework"
		),
	]
)
