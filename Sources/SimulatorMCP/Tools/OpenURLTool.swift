import MCP

enum OpenURLTool {
    static let name = "open_url"

    static let definition = Tool(
        name: name,
        description: "Open a URL (including deep links) in the simulator",
        inputSchema: .object([
            "udid": .object([
                "type": .string("string"),
                "description": .string("The UDID of the booted simulator"),
            ]),
            "url": .object([
                "type": .string("string"),
                "description": .string("The URL to open (e.g. https://example.com or myapp://path)"),
            ]),
        ])
    )

    static func run(arguments: [String: Value]?, runner: ProcessRunner) async throws -> CallTool.Result {
        let udid = try requiredString("udid", from: arguments)
        let url = try requiredString("url", from: arguments)
        _ = try await runner.simctl("openurl", udid, url)
        return CallTool.Result(content: [.text("URL '\(url)' opened on simulator \(udid).")])
    }
}
