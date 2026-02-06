import MCP

enum InstallAppTool {
    static let name = "install_app"

    static let definition = Tool(
        name: name,
        description: "Install an app (.app bundle) on a booted simulator",
        inputSchema: jsonSchema(
            properties: [
                "udid": stringProperty("The UDID of the booted simulator"),
                "app_path": stringProperty("The path to the .app bundle to install"),
            ],
            required: ["udid", "app_path"]
        )
    )

    static func run(arguments: [String: Value]?, runner: ProcessRunner) async throws -> CallTool.Result {
        let udid = try requiredString("udid", from: arguments)
        let appPath = try requiredString("app_path", from: arguments)
        _ = try await runner.simctl("install", udid, appPath)
        return CallTool.Result(content: [.text("App installed from '\(appPath)' on simulator \(udid).")])
    }
}
