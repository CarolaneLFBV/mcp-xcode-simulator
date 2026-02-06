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

    private func run(command: String, arguments: [String]) async throws -> Output {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        // Read pipes concurrently to avoid deadlock when both buffers fill up
        async let stdoutRead = readPipe(stdoutPipe)
        async let stderrRead = readPipe(stderrPipe)

        try process.run()

        let stdoutData = await stdoutRead
        let stderrData = await stderrRead

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

    private nonisolated func readPipe(_ pipe: Pipe) async -> Data {
        pipe.fileHandleForReading.readDataToEndOfFile()
    }
}
