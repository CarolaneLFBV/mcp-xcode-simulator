import MCP

enum BootSimulatorTool {
    static let name = "boot_simulator"

    static let definition = Tool(
        name: name,
        description: "Boot an iOS simulator by its UDID",
        inputSchema: jsonSchema(
            properties: [
                "udid": stringProperty("The UDID of the simulator to boot"),
            ],
            required: ["udid"]
        ),
        annotations: .init(readOnlyHint: false, openWorldHint: true)
    )

    static func run(arguments: [String: Value]?, runner: ProcessRunner) async throws -> CallTool.Result {
        let udid = try requiredString("udid", from: arguments)
        _ = try await runner.simctl("boot", udid)
        return CallTool.Result(content: [.text("Simulator \(udid) booted successfully.")])
    }
}
