import ArgumentParser
import Foundation

@main
struct PackageStateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A utility for performing maths.",
        subcommands: [VersionStatus.self, Changelog.self],
        defaultSubcommand: VersionStatus.self
    )
}
