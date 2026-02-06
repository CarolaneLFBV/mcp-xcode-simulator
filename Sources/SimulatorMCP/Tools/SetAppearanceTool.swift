import MCP

enum SetAppearanceTool {
    static let name = "set_appearance"

    static let definition = Tool(
        name: name,
        description: "Switch the simulator between light and dark mode",
        inputSchema: .object([
            "udid": .object([
                "type": .string("string"),
                "description": .string("The UDID of the booted simulator"),
            ]),
            "appearance": .object([
                "type": .string("string"),
                "description": .string("The appearance mode: 'light' or 'dark'"),
            ]),
        ])
    )

    static func run(arguments: [String: Value]?, runner: ProcessRunner) async throws -> CallTool.Result {
        let udid = try requiredString("udid", from: arguments)
        let appearance = try requiredString("appearance", from: arguments)

        guard appearance == "light" || appearance == "dark" else {
            throw SimulatorError.invalidParameter(name: "appearance", value: appearance)
        }

        _ = try await runner.simctl("ui", udid, "appearance", appearance)
        return CallTool.Result(content: [.text("Simulator \(udid) appearance set to \(appearance).")])
    }
}
