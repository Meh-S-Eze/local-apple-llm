// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "LocalLLM",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "LocalLLM",
            targets: ["LocalLLM"]),
        .executable(
            name: "LocalLLMServer",
            targets: ["LocalLLMServer"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0")
    ],
    targets: [
        .target(
            name: "LocalLLM",
            dependencies: []),
        .executableTarget(
            name: "LocalLLMServer",
            dependencies: [
                "LocalLLM",
                .product(name: "Vapor", package: "vapor")
            ]),
        .testTarget(
            name: "LocalLLMTests",
            dependencies: ["LocalLLM"])
    ]
) 