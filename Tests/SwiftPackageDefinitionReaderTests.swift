import Foundation
@testable import SPMVersionStatus
import Testing
import XcodeProj

struct SwiftPackageDefinitionReaderTests {
    @Test("Extract pacakges and versions from content")
    func extractPackagesAndVersions() throws {
        let content = """
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
                )
            ]
        )
        """

        let packages = try SwiftPackageDefinitionReader.parsePackages(from: content)

        #expect(
            packages == [
                .init(
                    repositoryURL: URL(string: "https://github.com/apple/swift-argument-parser")!,
                    versionRequirement: .upToNextMajorVersion("1.0.0")
                ),
                .init(
                    repositoryURL: URL(string: "https://github.com/tuist/XcodeProj.git")!,
                    versionRequirement: .upToNextMajorVersion("8.12.0")
                ),
                .init(
                    repositoryURL: URL(string: "https://github.com/mxcl/Version.git")!,
                    versionRequirement: .upToNextMajorVersion("2.0.0")
                ),
                .init(
                    repositoryURL: URL(string: "https://github.com/mxcl/Chalk.git")!,
                    versionRequirement: .upToNextMajorVersion("0.1.0")
                ),
            ]
        )
    }
}
