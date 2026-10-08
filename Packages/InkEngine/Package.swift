// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "InkEngine",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "InkEngine", targets: ["InkEngine"]),
    ],
    targets: [
        .target(name: "InkEngine"),
        .testTarget(name: "InkEngineTests", dependencies: ["InkEngine"]),
    ]
)
