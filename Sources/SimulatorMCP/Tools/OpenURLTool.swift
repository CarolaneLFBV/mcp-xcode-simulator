import MCP

enum OpenURLTool {
    static let name = "open_url"

    static let definition = Tool(
        name: name,
        description: "Open a URL (including deep links) in the simulator",
        inputSchema: jsonSchema(
            properties: [
                "udid": stringProperty("The UDID of the booted simulator"),
                "url": stringProperty("The URL to open (e.g. https://example.com or myapp://path)"),
            ],
            required: ["udid", "url"]
        )
    )

    static func run(arguments: [String: Value]?, runner: ProcessRunner) async throws -> CallTool.Result {
        let udid = try requiredString("udid", from: arguments)
        let url = try requiredString("url", from: arguments)
        _ = try await runner.simctl("openurl", udid, url)
        return CallTool.Result(content: [.text("URL '\(url)' opened on simulator \(udid).")])
    }
}
