// swift-tools-version: 5.7

// Douglas Hill, May 2023

import PackageDescription

let package = Package(
	name: "generate"
	, platforms: [
		.macOS(.v13),
	]
	, dependencies: [
		.package(path: "markdown"),
	]
	, targets: [
		.executableTarget(
			name: "generate"
			, dependencies: [.product(name: "Markdown", package: "markdown")]
			, path: ""
			, exclude: ["Content", "Output", "markdown", "cmark", "build.sh"]
		),
	]
)
