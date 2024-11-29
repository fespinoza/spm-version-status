// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SPMVersionStatus",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/tuist/XcodeProj.git", from: "8.12.0"),
        .package(url: "https://github.com/mxcl/Version.git", from: "2.0.0"),
        .package(url: "https://github.com/mxcl/Chalk.git", from: "0.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "SPMVersionStatus",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "XcodeProj",
                "Version",
                "Chalk",
            ]
        ),
        .testTarget(
            name: "SPMVersionStatusTests",
            dependencies: ["SPMVersionStatus"]
        ),
    ]
)
