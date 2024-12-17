import Foundation

struct ReleaseData: Codable {
    let name: String
    let tagName: String
    let publishedAt: Date
    let body: String

    var terminalTitle: String {
        "\("## \(name) - \(publishedAt.formatted(date: .abbreviated, time: .omitted))", color: .blue)"
    }

    var terminalBody: String {
        """
        ```
        \(body)
        ```
        """
    }

    var terminalMarkdown: String {
        """
        \(terminalTitle)

        \(terminalBody)
        """
    }
}
