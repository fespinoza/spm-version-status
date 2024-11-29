import Foundation

struct ResolvedContainer: Decodable {
    let pins: [PinnedVersion]

    struct PinnedVersion: Decodable {
        let location: URL
        let state: State
    }

    struct State: Decodable {
        let revision: String
        let version: String
    }
}
