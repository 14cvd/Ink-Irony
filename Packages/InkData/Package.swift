// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "InkData",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "InkData", targets: ["InkData"]),
    ],
    targets: [
        .target(name: "InkData"),
        // Byte-for-byte copy of the v1.2 model, used only by tests to write a store the way v1 did.
        .target(name: "InkDataV1Fixture", path: "Sources/InkDataV1Fixture"),
        .testTarget(name: "InkDataTests", dependencies: ["InkData", "InkDataV1Fixture"]),
    ]
)
