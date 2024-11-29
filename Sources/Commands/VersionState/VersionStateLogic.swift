import Foundation
import Version

class VersionStateLogic {
    let inputReader: InputReader

    init(inputReader: InputReader) {
        self.inputReader = inputReader
    }

    func run() async throws {
        let xcodePackages = try inputReader.readDependencyDefinitions()
        let pinnedPackageVersions = try inputReader.readPinnedPackageVersions()

        let latestVersions = try fetchLatestPackageVersions(for: xcodePackages)

        let buildPackage: (PackageDependencyDeclaration) -> PackageState? = { package in
            self.packageInfo(
                for: package,
                pinnedPackageVersions: pinnedPackageVersions,
                latestVersions: latestVersions
            )
        }

        xcodePackages
            .compactMap(buildPackage)
            .sorted(by: { $0.comparison.rawValue < $1.comparison.rawValue })
            .forEach { print($0.stateDescriptionForTerminal) }
    }

    private func fetchLatestPackageVersions(for packages: [PackageDependencyDeclaration]) throws -> [URL: Version] {
        try packages.reduce(into: [:]) { partialResult, package in
            let latestVersion = try Utils
                .getTags(for: package.repositoryURL)
                .compactMap { Version($0) }
                .sorted()
                .last
            partialResult[package.repositoryURL] = latestVersion
        }
    }

    private func packageInfo(
        for package: PackageDependencyDeclaration,
        pinnedPackageVersions: [URL: Version],
        latestVersions: [URL: Version]
    ) -> PackageState? {
        guard
            let pinnedPackageVersion = pinnedPackageVersions[package.repositoryURL],
            let latestPackageVersion = latestVersions[package.repositoryURL]
        else { return nil }

        return PackageState(
            url: package.repositoryURL,
            versionRequirement: package.versionRequirement,
            pinnedVersion: pinnedPackageVersion,
            latestVersion: latestPackageVersion
        )
    }
}
