import Foundation
import Version

enum Utils {
    static func getTags(for repo: URL) throws -> [String] {
        let v1 = try Utils.shell(
            "git -c 'versionsort.suffix=-' ls-remote --exit-code --refs --sort='version:refname' --tags \(repo)"
        )

        let versions = v1.components(separatedBy: CharacterSet.newlines)

        let regex = try NSRegularExpression(pattern: "(?:/v?)([0-9]+\\.[0-9]+\\.[0-9]+)$", options: [])

        return versions.compactMap { line in
            let range = NSRange(location: 0, length: line.utf16.count)
            if
                let match = regex.firstMatch(in: line, options: [], range: range),
                let versionRange = Range(match.range(at: 1), in: line)
            {
                return String(line[versionRange])
            }

            return nil
        }
    }

    /// Runs a shell command and returns the output
    @discardableResult static func shell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/sh"
        task.standardInput = nil
        try task.run()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        return output
    }

    /// Runs a command and check the status
    static func checkStatus(for command: String) throws -> Int {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/sh"
        task.standardInput = nil
        try task.run()
        task.waitUntilExit()

        return Int(task.terminationStatus)
    }

    static func readPinnedPacakgedVersions(from fileURL: URL) throws -> [URL: Version] {
        let resolvedFile = try Data(contentsOf: fileURL)
        let resolved = try JSONDecoder().decode(ResolvedContainer.self, from: resolvedFile)

        return resolved
            .pins
            .reduce(into: [:]) { partialResult, pin in
                guard let version = Version(pin.state.version) else { return }
                partialResult[pin.location] = version
            }
    }
}
