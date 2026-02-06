import Foundation
import MCP

enum RunProjectTool {
    static let name = "run_project"

    static let definition = Tool(
        name: name,
        description: """
            Build, install, and launch an Xcode project on a simulator in one step. \
            Handles the full pipeline: xcodebuild → simctl install → simctl launch. \
            Use this instead of calling build_project, install_app, and launch_app separately.
            """,
        inputSchema: jsonSchema(
            properties: [
                "project_path": stringProperty("Path to the Xcode project directory"),
                "scheme": stringProperty("The Xcode scheme to build and run"),
                "bundle_id": stringProperty("The app's bundle identifier (e.g. com.example.MyApp)"),
                "device_name": stringProperty("Simulator name (default: 'iPhone 16 Pro')"),
            ],
            required: ["project_path", "scheme", "bundle_id"]
        )
    )

    static func run(arguments: [String: Value]?, runner: ProcessRunner) async throws -> CallTool.Result {
        let projectPath = try requiredString("project_path", from: arguments)
        let scheme = try requiredString("scheme", from: arguments)
        let bundleId = try requiredString("bundle_id", from: arguments)
        let deviceName = arguments?["device_name"]?.stringValue ?? "iPhone 16 Pro"

        var steps: [String] = []

        // Step 1: Find or boot a simulator
        let destination = "platform=iOS Simulator,name=\(deviceName),OS=latest"
        steps.append("[1/4] Using simulator: \(deviceName)")

        // Step 2: Build
        steps.append("[2/4] Building scheme '\(scheme)'...")

        let fileManager = FileManager.default
        let projectURL = URL(fileURLWithPath: projectPath)
        let contents = (try? fileManager.contentsOfDirectory(atPath: projectPath)) ?? []

        var buildArgs = [
            "build",
            "-scheme", scheme,
            "-destination", destination,
            "-derivedDataPath", "\(projectPath)/DerivedData",
        ]

        if let workspace = contents.first(where: { $0.hasSuffix(".xcworkspace") }) {
            buildArgs += ["-workspace", projectURL.appendingPathComponent(workspace).path]
        } else if let project = contents.first(where: { $0.hasSuffix(".xcodeproj") }) {
            buildArgs += ["-project", projectURL.appendingPathComponent(project).path]
        }

        _ = try await runner.xcodebuild(buildArgs)
        steps.append("[2/4] Build succeeded.")

        // Step 3: Install
        let appPath = "\(projectPath)/DerivedData/Build/Products/Debug-iphonesimulator/\(scheme).app"

        guard fileManager.fileExists(atPath: appPath) else {
            throw SimulatorError.fileNotFound(appPath)
        }

        steps.append("[3/4] Installing app on simulator...")
        _ = try await runner.simctl("install", "booted", appPath)
        steps.append("[3/4] App installed.")

        // Step 4: Launch
        steps.append("[4/4] Launching \(bundleId)...")
        do {
            _ = try await runner.simctl("launch", "--console-pty", "booted", bundleId)
            steps.append("[4/4] App launched successfully.")
        } catch let error as SimulatorError {
            steps.append("[4/4] Launch failed: \(error.description)")
            steps.append("")
            steps.append("Tip: If the app crashes on launch, check ~/Library/Logs/DiagnosticReports/ for crash reports.")
            return CallTool.Result(content: [.text(steps.joined(separator: "\n"))], isError: true)
        }

        return CallTool.Result(content: [.text(steps.joined(separator: "\n"))])
    }
}
