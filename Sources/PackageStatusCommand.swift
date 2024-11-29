import ArgumentParser
import Chalk
import Foundation
import Version
import XcodeProj

@main
struct PackageStateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A utility for performing maths.",
        subcommands: [VersionState.self],
        defaultSubcommand: VersionState.self
    )
}
