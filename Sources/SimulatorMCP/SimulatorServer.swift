import Foundation
import MCP

enum SimulatorServer {
    static func start() async throws {
        fputs("[ios-simulator-mcp] Starting server...\n", stderr)

        let server = Server(
            name: "ios-simulator-mcp",
            version: "1.0.0",
            capabilities: .init(tools: .init(listChanged: false))
        )

        await server.withMethodHandler(ListTools.self) { _ in
            ListTools.Result(tools: ToolRegistry.allTools)
        }

        await server.withMethodHandler(CallTool.self) { params in
            do {
                return try await ToolRegistry.call(params.name, arguments: params.arguments)
            } catch let error as SimulatorError {
                return CallTool.Result(content: [.text("Error: \(error.description)")], isError: true)
            } catch {
                return CallTool.Result(content: [.text("Error: \(error.localizedDescription)")], isError: true)
            }
        }

        let transport = StdioTransport()
        try await server.start(transport: transport)

        fputs("[ios-simulator-mcp] Server started, waiting for requests...\n", stderr)

        await server.waitUntilCompleted()
    }
}
