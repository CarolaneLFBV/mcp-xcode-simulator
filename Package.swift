// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "ios-simulator-mcp",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.10.2"),
    ],
    targets: [
        .executableTarget(
            name: "ios-simulator-mcp",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk"),
            ],
            path: "Sources/SimulatorMCP"
        ),
    ]
)
