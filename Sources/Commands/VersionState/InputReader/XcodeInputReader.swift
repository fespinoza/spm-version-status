import Foundation
import Version
import XcodeProj

class XcodeInputReader: InputReader {
    let xcodeProjectPath: String
    let xcworkspacePath: String?

    init(xcodeProjectPath: String, xcworkspacePath: String?) {
        self.xcodeProjectPath = xcodeProjectPath
        self.xcworkspacePath = xcworkspacePath
    }

    func readDependencyDefinitions() throws -> [PackageDependencyDeclaration] {
        let xcodeproj = try XcodeProj(pathString: xcodeProjectPath)

        return xcodeproj
            .pbxproj
            .rootObject?
            .remotePackages
            .compactMap { package -> PackageDependencyDeclaration? in
                guard
                    let repositoryURL = package.repositoryURL.flatMap({ URL(string: $0) }),
                    let versionRequirement = package.versionRequirement
                else { return nil }

                return PackageDependencyDeclaration(
                    repositoryURL: repositoryURL,
                    versionRequirement: versionRequirement
                )
            } ?? []
    }

    func readPinnedPackageVersions() throws -> [URL: Version] {
        let resolvedURL = if let xcworkspacePath {
            URL(fileURLWithPath: "\(xcworkspacePath)/xcshareddata/swiftpm/Package.resolved")
        } else {
            URL(fileURLWithPath: "\(xcodeProjectPath)/project.xcworkspace/xcshareddata/swiftpm/Package.resolved")
        }
        let resolvedFile = try Data(contentsOf: resolvedURL)
        let resolved = try JSONDecoder().decode(ResolvedContainer.self, from: resolvedFile)

        return resolved
            .pins
            .reduce(into: [:]) { partialResult, pin in
                guard let version = Version(pin.state.version) else { return }
                partialResult[pin.location] = version
            }
    }
}
