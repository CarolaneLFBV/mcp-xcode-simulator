import Foundation
import MCP

enum BuildProjectTool {
    static let name = "build_project"

    static let definition = Tool(
        name: name,
        description: "Build an Xcode project for an iOS simulator. Returns the path to the built .app bundle.",
        inputSchema: .object([
            "project_path": .object([
                "type": .string("string"),
                "description": .string("Path to the Xcode project directory (containing .xcodeproj or .xcworkspace)"),
            ]),
            "scheme": .object([
                "type": .string("string"),
                "description": .string("The Xcode scheme to build"),
            ]),
            "device_name": .object([
                "type": .string("string"),
                "description": .string("Simulator device name (default: 'iPhone 16 Pro')"),
            ]),
        ])
    )

    static func run(arguments: [String: Value]?, runner: ProcessRunner) async throws -> CallTool.Result {
        let projectPath = try requiredString("project_path", from: arguments)
        let scheme = try requiredString("scheme", from: arguments)
        let deviceName = arguments?["device_name"]?.stringValue ?? "iPhone 16 Pro"

        let destination = "platform=iOS Simulator,name=\(deviceName),OS=latest"

        // Detect workspace vs project
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

        let output = try await runner.xcodebuild(buildArgs)

        // Extract the .app path from build output
        let appPath = extractAppPath(from: output.stdout, scheme: scheme, projectPath: projectPath)

        var result = "Build succeeded for scheme '\(scheme)'."
        if let appPath {
            result += "\nApp bundle: \(appPath)"
        }

        return CallTool.Result(content: [.text(result)])
    }

    private static func extractAppPath(from output: String, scheme: String, projectPath: String) -> String? {
        // Look for BUILT_PRODUCTS_DIR in build settings output
        for line in output.components(separatedBy: "\n") {
            if line.contains("Touch ") && line.hasSuffix(".app") {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if let range = trimmed.range(of: "/") {
                    return String(trimmed[range.lowerBound...])
                }
            }
        }

        // Fallback: construct expected path
        let derivedData = "\(projectPath)/DerivedData"
        let expectedPath = "\(derivedData)/Build/Products/Debug-iphonesimulator/\(scheme).app"
        if FileManager.default.fileExists(atPath: expectedPath) {
            return expectedPath
        }

        return nil
    }
}
