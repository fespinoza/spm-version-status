import Foundation
import Version

protocol InputReader {
    func readDependencyDefinitions() throws -> [PackageDependencyDeclaration]
    func readPinnedPackageVersions() throws -> [URL: Version]
}
