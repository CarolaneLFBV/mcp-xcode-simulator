import Foundation

@main
struct SimulatorMCP {
    static func main() async throws {
        try await SimulatorServer.start()
    }
}
