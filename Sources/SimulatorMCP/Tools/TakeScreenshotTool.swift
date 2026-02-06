import Foundation
import MCP

enum TakeScreenshotTool {
    static let name = "take_screenshot"

    static let definition = Tool(
        name: name,
        description: "Take a screenshot of a booted simulator. Returns the image as base64-encoded PNG.",
        inputSchema: jsonSchema(
            properties: [
                "udid": stringProperty("The UDID of the booted simulator"),
            ],
            required: ["udid"]
        )
    )

    static func run(arguments: [String: Value]?, runner: ProcessRunner) async throws -> CallTool.Result {
        let udid = try requiredString("udid", from: arguments)

        let tempDir = FileManager.default.temporaryDirectory
        let screenshotPath = tempDir.appendingPathComponent("simulator_screenshot_\(UUID().uuidString).png").path

        defer {
            try? FileManager.default.removeItem(atPath: screenshotPath)
        }

        _ = try await runner.simctl("io", udid, "screenshot", screenshotPath)

        guard let imageData = FileManager.default.contents(atPath: screenshotPath) else {
            throw SimulatorError.screenshotFailed("Could not read screenshot file at \(screenshotPath)")
        }

        let base64 = imageData.base64EncodedString()

        return CallTool.Result(content: [
            .image(data: base64, mimeType: "image/png", metadata: nil),
        ])
    }
}
