import MCP

enum LaunchAppTool {
    static let name = "launch_app"

    static let definition = Tool(
        name: name,
        description: """
            Launch an app on a booted simulator using simctl (low-level). WARNING: This will \
            crash apps that depend on CloudKit, entitlements, Keychain, or App Groups. For \
            most Xcode projects, use run_project instead which triggers the full Xcode Run \
            pipeline with proper signing and environment setup.
            """,
        inputSchema: jsonSchema(
            properties: [
                "udid": stringProperty("The UDID of the booted simulator"),
                "bundle_id": stringProperty("The bundle identifier of the app to launch (e.g. com.example.MyApp)"),
            ],
            required: ["udid", "bundle_id"]
        )
    )

    static func run(arguments: [String: Value]?, runner: ProcessRunner) async throws -> CallTool.Result {
        let udid = try requiredString("udid", from: arguments)
        let bundleId = try requiredString("bundle_id", from: arguments)
        _ = try await runner.simctl("launch", udid, bundleId)
        return CallTool.Result(content: [.text("App \(bundleId) launched on simulator \(udid).")])
    }
}
