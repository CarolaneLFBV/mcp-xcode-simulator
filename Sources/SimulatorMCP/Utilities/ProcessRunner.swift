import Foundation

actor ProcessRunner {
    struct Output: Sendable {
        let stdout: String
        let stderr: String
        let exitCode: Int32
    }

    func simctl(_ arguments: String...) async throws -> Output {
        try await run(command: "/usr/bin/xcrun", arguments: ["simctl"] + arguments)
    }

    func xcodebuild(_ arguments: [String]) async throws -> Output {
        try await run(command: "/usr/bin/xcrun", arguments: ["xcodebuild"] + arguments)
    }

    func osascript(_ script: String) async throws -> Output {
        try await run(command: "/usr/bin/osascript", arguments: ["-e", script])
    }

    private func run(command: String, arguments: [String]) async throws -> Output {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        process.waitUntilExit()

        let output = Output(
            stdout: String(data: stdoutData, encoding: .utf8) ?? "",
            stderr: String(data: stderrData, encoding: .utf8) ?? "",
            exitCode: process.terminationStatus
        )

        if process.terminationStatus != 0 {
            let commandString = ([command] + arguments).joined(separator: " ")
            throw SimulatorError.commandFailed(
                command: commandString,
                exitCode: process.terminationStatus,
                stderr: output.stderr
            )
        }

        return output
    }
}
