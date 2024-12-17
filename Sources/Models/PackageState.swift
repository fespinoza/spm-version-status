import Foundation
import Version
import XcodeProj

struct PackageState {
    let url: URL
    let versionRequirement: VersionRequirement?
    let pinnedVersion: Version
    let latestVersion: Version

    var name: String {
        url.lastPathComponent.replacing(/\.git$/, with: "")
    }

    var comparison: PackageComparison {
        if pinnedVersion < latestVersion {
            .canUpdate
        } else if pinnedVersion == latestVersion {
            .upToDate
        } else {
            .unexpectedError
        }
    }

    var canUpdate: Bool {
        comparison == .canUpdate
    }

    var stateDescriptionForTerminal: String {
        switch comparison {
        case .canUpdate:
            """
            \(url, color: .yellow) \
            \("can update from", color: .yellow) \
            '\(pinnedVersion, color: .yellow, style: .bold)' \
            \("to", color: .yellow) \
            '\(latestVersion, color: .yellow, style: .bold)'
            """

        case .upToDate:
            "\("\(url) is up to date!", color: .green)"

        case .unexpectedError:
            "\(url) \("something is wrong with the script here", color: .red) - \(pinnedVersion) - \(latestVersion)"
        }
    }

    var changelogStateForTerminal: String {
        """

        Changelog for \(url, color: .green, style: .bold) \
        from \
        '\(pinnedVersion, color: .green, style: .bold)' \
        to \
        '\(latestVersion, color: .green, style: .bold)'

        """
    }
}

struct PackageDependencyDeclaration: Equatable {
    let repositoryURL: URL
    let versionRequirement: VersionRequirement
}

enum PackageComparison: Int {
    case upToDate
    case canUpdate
    case unexpectedError
}

enum SwiftPackageDefinitionReader {
    static func parsePackages(from content: String) throws -> [PackageDependencyDeclaration] {
        var results: [PackageDependencyDeclaration] = []

        content.enumerateLines { line, _ in
            guard let package = parsePackage(from: line) else { return }
            results.append(package)
        }

        return results
    }

    private static func parsePackage(from line: String) -> PackageDependencyDeclaration? {
        let dependenciesRegex = /.*\.package\s*\(\s*url:\s*\"(?<urlContent>[^,]+)\"\s*,\s*from:\s*\"(?<versionContent>[^,]+)\"\s*\)\s*.*/

        guard
            let match = line.firstMatch(of: dependenciesRegex),
            let url = URL(string: String(match.urlContent))
        else { return nil }

        return PackageDependencyDeclaration(
            repositoryURL: url,
            versionRequirement: .upToNextMajorVersion(String(match.versionContent))
        )
    }
}
