// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SimulaMiniGameSDK",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SimulaMiniGameSDK",
            targets: ["SimulaMiniGameSDK"]
        )
    ],
    targets: [
        .target(
            name: "SimulaMiniGameSDK",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SimulaMiniGameSDKTests",
            dependencies: ["SimulaMiniGameSDK"]
        )
    ]
)
