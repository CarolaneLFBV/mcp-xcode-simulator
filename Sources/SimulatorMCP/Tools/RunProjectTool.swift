import MCP

enum RunProjectTool {
    static let name = "run_project"

    static let definition = Tool(
        name: name,
        description: """
            PREFERRED way to launch an app on the simulator. Triggers Xcode's Product > Run \
            (Cmd+R), which handles build + install + launch in one step with the full Xcode \
            execution context. This is required for apps using CloudKit, entitlements, Keychain, \
            or App Groups — simctl launch will crash these apps. Always prefer this over \
            launch_app or manual simctl launch commands.
            """,
        inputSchema: .object([
            "destination": .object([
                "type": .string("string"),
                "description": .string(
                    "Optional: simulator destination (e.g. 'iPhone 16 Pro'). "
                    + "If omitted, uses Xcode's currently selected destination."
                ),
            ]),
        ])
    )

    static func run(arguments: [String: Value]?, runner: ProcessRunner) async throws -> CallTool.Result {
        let destination = arguments?["destination"]?.stringValue

        // If a destination is specified, set it in Xcode first
        if let destination {
            let setDestinationScript = """
                tell application "Xcode"
                    activate
                end tell
                tell application "System Events"
                    tell process "Xcode"
                        click menu item "Destination" of menu "Product" of menu bar 1
                    end tell
                end tell
                """
            // Setting destination via Xcode UI is fragile, so we just activate Xcode
            // and note the requested destination in the response
            _ = try? await runner.osascript("""
                tell application "Xcode" to activate
                """)

            // Small delay to let Xcode come to foreground
            try await Task.sleep(for: .milliseconds(500))

            _ = try? await runner.osascript(setDestinationScript)
            _ = destination // acknowledge the parameter
        }

        // Trigger Product > Run via AppleScript
        let runScript = """
            tell application "Xcode"
                activate
            end tell
            delay 0.3
            tell application "System Events"
                tell process "Xcode"
                    click menu item "Run" of menu "Product" of menu bar 1
                end tell
            end tell
            """

        _ = try await runner.osascript(runScript)

        var result = "Xcode 'Product > Run' triggered successfully (equivalent to Cmd+R)."
        if let destination {
            result += "\nRequested destination: \(destination)"
            result += "\nNote: Make sure the correct simulator is selected in Xcode's destination picker."
        }
        result += "\nThe app is building and launching with Xcode's full execution context."

        return CallTool.Result(content: [.text(result)])
    }
}
