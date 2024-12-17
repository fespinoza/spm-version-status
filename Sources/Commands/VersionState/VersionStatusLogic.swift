import Foundation
import Version

class VersionStatusLogic {
    let inputReader: InputReader
    let mode: VersionStatus.Mode

    init(inputReader: InputReader, mode: VersionStatus.Mode) {
        self.inputReader = inputReader
        self.mode = mode
    }

    func run() async throws {
        let declaredDependencies = try inputReader.readDependencyDefinitions()
        let pinnedPackageVersions = try inputReader.readPinnedPackageVersions()

        let sourcePackages: [URL] = if mode == .onlyDeclaredDependencies {
            declaredDependencies.map(\.repositoryURL)
        } else {
            Array(pinnedPackageVersions.keys)
        }

        let latestVersions = try CommonPackageLogic.fetchLatestPackageVersions(for: sourcePackages)

        let buildPackage: (URL) -> PackageState? = { packageURL in
            CommonPackageLogic.packageInfo(
                for: packageURL,
                versionRequirement: declaredDependencies
                    .first(where: { $0.repositoryURL == packageURL })?
                    .versionRequirement,
                pinnedPackageVersions: pinnedPackageVersions,
                latestVersions: latestVersions
            )
        }

        sourcePackages
            .compactMap(buildPackage)
            .sorted(by: { $0.comparison.rawValue < $1.comparison.rawValue })
            .forEach { print($0.stateDescriptionForTerminal) }
    }
}
