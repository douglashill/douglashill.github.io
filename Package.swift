// swift-tools-version: 5.7

// Douglas Hill, May 2023

import PackageDescription

let package = Package(
	name: "generate"
	, platforms: [
		.macOS(.v13),
	]
	, dependencies: [
		.package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
	]
	, targets: [
		.executableTarget(
			name: "generate"
			, dependencies: [.product(name: "Markdown", package: "swift-markdown")]
			, path: ""
			, exclude: ["Content", "Output"]
//			, swiftSettings: [
//				.define("ENABLE_PERFORMANCE_LOGGING")
//			]
		),
	]
)
