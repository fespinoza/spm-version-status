import Foundation
import Version

class SwiftPackageInputReader: InputReader {
    let packageSwiftPath: String
    let packageResolvedPath: String

    init(packageSwiftPath: String, packageResolvedPath: String) {
        self.packageSwiftPath = packageSwiftPath
        self.packageResolvedPath = packageResolvedPath
    }

    func readDependencyDefinitions() throws -> [PackageDependencyDeclaration] {
        let packageSwiftContent = try String(contentsOf: URL(fileURLWithPath: packageSwiftPath), encoding: .utf8)
        return try SwiftPackageDefinitionReader.parsePackages(from: packageSwiftContent)
    }

    func readPinnedPackageVersions() throws -> [URL: Version] {
        try Utils.readPinnedPacakgedVersions(from: URL(fileURLWithPath: packageResolvedPath))
    }
}
