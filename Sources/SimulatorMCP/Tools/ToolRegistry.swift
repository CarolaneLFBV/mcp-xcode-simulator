import MCP

enum ToolRegistry {
    static let runner = ProcessRunner()

    static var allTools: [Tool] {
        [
            ListSimulatorsTool.definition,
            BootSimulatorTool.definition,
            ShutdownSimulatorTool.definition,
            BuildProjectTool.definition,
            InstallAppTool.definition,
            LaunchAppTool.definition,
            TerminateAppTool.definition,
            TakeScreenshotTool.definition,
            SetAppearanceTool.definition,
            OpenURLTool.definition,
        ]
    }

    static func call(_ name: String, arguments: [String: Value]?) async throws -> CallTool.Result {
        switch name {
        case ListSimulatorsTool.name:
            try await ListSimulatorsTool.run(arguments: arguments, runner: runner)
        case BootSimulatorTool.name:
            try await BootSimulatorTool.run(arguments: arguments, runner: runner)
        case ShutdownSimulatorTool.name:
            try await ShutdownSimulatorTool.run(arguments: arguments, runner: runner)
        case BuildProjectTool.name:
            try await BuildProjectTool.run(arguments: arguments, runner: runner)
        case InstallAppTool.name:
            try await InstallAppTool.run(arguments: arguments, runner: runner)
        case LaunchAppTool.name:
            try await LaunchAppTool.run(arguments: arguments, runner: runner)
        case TerminateAppTool.name:
            try await TerminateAppTool.run(arguments: arguments, runner: runner)
        case TakeScreenshotTool.name:
            try await TakeScreenshotTool.run(arguments: arguments, runner: runner)
        case SetAppearanceTool.name:
            try await SetAppearanceTool.run(arguments: arguments, runner: runner)
        case OpenURLTool.name:
            try await OpenURLTool.run(arguments: arguments, runner: runner)
        default:
            throw SimulatorError.unknownTool(name)
        }
    }
}
