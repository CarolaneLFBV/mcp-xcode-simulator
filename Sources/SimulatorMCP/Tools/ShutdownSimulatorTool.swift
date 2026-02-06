import MCP

enum ShutdownSimulatorTool {
    static let name = "shutdown_simulator"

    static let definition = Tool(
        name: name,
        description: "Shutdown a running iOS simulator by its UDID",
        inputSchema: .object([
            "udid": .object([
                "type": .string("string"),
                "description": .string("The UDID of the simulator to shut down"),
            ]),
        ]),
        annotations: .init(readOnlyHint: false, openWorldHint: true)
    )

    static func run(arguments: [String: Value]?, runner: ProcessRunner) async throws -> CallTool.Result {
        let udid = try requiredString("udid", from: arguments)
        _ = try await runner.simctl("shutdown", udid)
        return CallTool.Result(content: [.text("Simulator \(udid) shut down successfully.")])
    }
}
