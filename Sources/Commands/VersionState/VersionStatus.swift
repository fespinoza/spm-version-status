import ArgumentParser
import Foundation

struct VersionStatus: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(
        abstract: """
        Checks the versions of all imported packages in the project and compares them to their latest versions
        """
    )

    @Option var mode: Mode = .onlyDeclaredDependencies

    func run() async throws {
        let contents = try FileManager.default.contentsOfDirectory(atPath: FileManager.default.currentDirectoryPath)

        if let xcodeProjectPath = contents.first(where: { $0.contains(".xcodeproj") }) {
            print("Checking \(xcodeProjectPath)")

            let xcodeReader = XcodeInputReader(
                xcodeProjectPath: xcodeProjectPath,
                xcworkspacePath: contents.first(where: { $0.contains(".xcworkspace") })
            )

            try await VersionStatusLogic(inputReader: xcodeReader, mode: mode).run()

        } else if let packageSwiftPath = contents.first(where: { $0 == "Package.swift" }),
                  let packageResolvedPath = contents.first(where: { $0 == "Package.resolved" })
        {
            print("Checking \(packageSwiftPath)")

            let packageReader = SwiftPackageInputReader(
                packageSwiftPath: packageSwiftPath,
                packageResolvedPath: packageResolvedPath
            )

            try await VersionStatusLogic(inputReader: packageReader, mode: mode).run()
        } else {
            print("No .xcodeproj nor Package.swift file found")
        }
    }
}

extension VersionStatus {
    enum Mode: String, ExpressibleByArgument, CaseIterable {
        case onlyDeclaredDependencies
        /// also include transient dependencies
        case all
    }
}
