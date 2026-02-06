import MCP

enum TerminateAppTool {
    static let name = "terminate_app"

    static let definition = Tool(
        name: name,
        description: "Terminate a running app on a booted simulator",
        inputSchema: jsonSchema(
            properties: [
                "udid": stringProperty("The UDID of the booted simulator"),
                "bundle_id": stringProperty("The bundle identifier of the app to terminate"),
            ],
            required: ["udid", "bundle_id"]
        )
    )

    static func run(arguments: [String: Value]?, runner: ProcessRunner) async throws -> CallTool.Result {
        let udid = try requiredString("udid", from: arguments)
        let bundleId = try requiredString("bundle_id", from: arguments)
        _ = try await runner.simctl("terminate", udid, bundleId)
        return CallTool.Result(content: [.text("App \(bundleId) terminated on simulator \(udid).")])
    }
}
