import ArgumentParser
import Foundation

struct Changelog: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "changelog",
        abstract: """
        Gets the changelog from the github releases of versions superior to the current version of a package.

        It requires the GitHub command line installed to work.
        """
    )

    @Argument var packageName: String?
    @Flag var list: Bool = false

    func run() async throws {
        let contents = try FileManager.default.contentsOfDirectory(atPath: FileManager.default.currentDirectoryPath)

        if let xcodeProjectPath = contents.first(where: { $0.contains(".xcodeproj") }) {
            print("Checking \(xcodeProjectPath)")

            let xcodeReader = XcodeInputReader(
                xcodeProjectPath: xcodeProjectPath,
                xcworkspacePath: contents.first(where: { $0.contains(".xcworkspace") })
            )

            try await ChangelogLogic(inputReader: xcodeReader).run(packageName: packageName, onlyListVersions: list)

        } else if let packageSwiftPath = contents.first(where: { $0 == "Package.swift" }),
                  let packageResolvedPath = contents.first(where: { $0 == "Package.resolved" })
        {
            print("Checking \(packageSwiftPath)")

            let packageReader = SwiftPackageInputReader(
                packageSwiftPath: packageSwiftPath,
                packageResolvedPath: packageResolvedPath
            )

            try await ChangelogLogic(inputReader: packageReader).run(packageName: packageName, onlyListVersions: list)
        } else {
            print("No .xcodeproj nor Package.swift file found")
        }
    }
}
