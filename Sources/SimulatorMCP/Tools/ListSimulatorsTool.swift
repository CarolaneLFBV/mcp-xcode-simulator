import MCP

enum ListSimulatorsTool {
    static let name = "list_simulators"

    static let definition = Tool(
        name: name,
        description: "List all available iOS simulators with their UDID, name, state, and runtime",
        inputSchema: .object([:])
    )

    static func run(arguments: [String: Value]?, runner: ProcessRunner) async throws -> CallTool.Result {
        let output = try await runner.simctl("list", "devices", "available", "-j")
        return CallTool.Result(content: [.text(output.stdout)])
    }
}
