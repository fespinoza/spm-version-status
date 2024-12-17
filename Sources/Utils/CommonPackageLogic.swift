import Foundation
import Version

enum CommonPackageLogic {
    static func fetchLatestPackageVersions(for packages: [URL]) throws -> [URL: [Version]] {
        try packages.reduce(into: [:]) { partialResult, packageURL in
            let latestVersions = try Utils
                .getTags(for: packageURL)
                .compactMap { Version($0) }
                .sorted()
            partialResult[packageURL] = latestVersions
        }
    }

    static func packageInfo(
        for package: PackageDependencyDeclaration,
        pinnedPackageVersions: [URL: Version],
        latestVersions: [URL: [Version]]
    ) -> PackageState? {
        packageInfo(
            for: package.repositoryURL,
            versionRequirement: package.versionRequirement,
            pinnedPackageVersions: pinnedPackageVersions,
            latestVersions: latestVersions
        )
    }

    static func packageInfo(
        for packageURL: URL,
        versionRequirement: VersionRequirement?,
        pinnedPackageVersions: [URL: Version],
        latestVersions: [URL: [Version]]
    ) -> PackageState? {
        guard
            let pinnedPackageVersion = pinnedPackageVersions[packageURL],
            let latestPackageVersion = latestVersions[packageURL]?.last
        else { return nil }

        return PackageState(
            url: packageURL,
            versionRequirement: versionRequirement,
            pinnedVersion: pinnedPackageVersion,
            latestVersion: latestPackageVersion
        )
    }
}
