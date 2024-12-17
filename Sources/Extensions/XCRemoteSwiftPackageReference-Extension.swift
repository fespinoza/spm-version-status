import XcodeProj

typealias VersionRequirement = XCRemoteSwiftPackageReference.VersionRequirement

extension VersionRequirement {
    var currentVersion: String? {
        switch self {
        case let .upToNextMajorVersion(string):
            string
        case let .upToNextMinorVersion(string):
            string
        case let .range(from, _):
            from
        case let .exact(string):
            string
        case .branch:
            nil
        case .revision:
            nil
        }
    }
}
