import Foundation

enum SimulatorError: Error, CustomStringConvertible {
    case commandFailed(command: String, exitCode: Int32, stderr: String)
    case missingParameter(String)
    case invalidParameter(name: String, value: String)
    case fileNotFound(String)
    case screenshotFailed(String)
    case unknownTool(String)

    var description: String {
        switch self {
        case .commandFailed(let command, let exitCode, let stderr):
            "Command '\(command)' failed with exit code \(exitCode): \(stderr)"
        case .missingParameter(let name):
            "Missing required parameter: \(name)"
        case .invalidParameter(let name, let value):
            "Invalid value '\(value)' for parameter '\(name)'"
        case .fileNotFound(let path):
            "File not found: \(path)"
        case .screenshotFailed(let reason):
            "Screenshot failed: \(reason)"
        case .unknownTool(let name):
            "Unknown tool: \(name)"
        }
    }
}
