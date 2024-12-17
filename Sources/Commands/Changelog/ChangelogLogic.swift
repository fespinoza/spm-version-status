import Chalk
import Foundation

class ChangelogLogic {
    let inputReader: InputReader

    init(inputReader: InputReader) {
        self.inputReader = inputReader
    }

    func run(packageName: String?, onlyListVersions: Bool) async throws {
        guard isGhInstalled else {
            print("the github command line 'gh' is not installed, please install it first.")
            return
        }

        let xcodePackages = try inputReader.readDependencyDefinitions()
        let pinnedPackageVersions = try inputReader.readPinnedPackageVersions()

        let latestVersions = try CommonPackageLogic.fetchLatestPackageVersions(for: xcodePackages.map(\.repositoryURL))

        let buildPackage: (PackageDependencyDeclaration) -> PackageState? = { package in
            CommonPackageLogic.packageInfo(
                for: package,
                pinnedPackageVersions: pinnedPackageVersions,
                latestVersions: latestVersions
            )
        }

        let filteredPackages = xcodePackages
            .compactMap(buildPackage)
            .sorted(by: { $0.comparison.rawValue < $1.comparison.rawValue })
            .filter(\.canUpdate)

        if filteredPackages.isEmpty {
            print("\("All packages are up to date!", color: .green)")
            return
        }

        let package: PackageState = try getPackage(packageName: packageName, from: filteredPackages)

        print(package.changelogStateForTerminal)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        for version in latestVersions[package.url] ?? [] where version > package.pinnedVersion {
            let changes = try Utils.shell(
                "gh release view \(version) --repo \(package.url) --json 'body,name,publishedAt,tagName'"
            )

            let releaseData = try decoder.decode(ReleaseData.self, from: changes.data(using: .utf8)!)

            if onlyListVersions {
                print(releaseData.terminalTitle)
            } else {
                print(releaseData.terminalMarkdown)
            }
        }
    }

    var isGhInstalled: Bool {
        do {
            return try (Utils.checkStatus(for: "gh --help")) == 0
        } catch {
            return false
        }
    }

    enum PackageMatchingError: Error {
        case noMatchByName(message: String)
        case noPackageByIndex(message: String)
    }

    func getPackage(packageName: String?, from filteredPackages: [PackageState]) throws -> PackageState {
        if let packageName {
            let foundPackage = filteredPackages
                .first(where: { cleanForComparison($0.name) == cleanForComparison(packageName) })

            guard let foundPackage else {
                let availabePackageNames = filteredPackages.map(\.name).joined(separator: ",")

                throw PackageMatchingError.noMatchByName(
                    message: "No package matches given \(packageName) in \(availabePackageNames)"
                )
            }

            return foundPackage
        } else {
            for (index, package) in filteredPackages.enumerated() {
                print("\(index): \(package.name)")
            }

            print("\nNumber package to get the changelog of:", terminator: " ")

            guard
                let line = readLine(),
                let index = Int(line),
                index >= 0, index < filteredPackages.count
            else {
                throw PackageMatchingError.noPackageByIndex(message: "No package found at index")
            }

            return filteredPackages[index]
        }
    }

    func cleanForComparison(_ string: String) -> String {
        string.lowercased().replacingOccurrences(of: "-", with: "_")
    }
}
