// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "TokenMeterKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(name: "TokenMeterKit", targets: ["TokenMeterKit"]),
        .executable(name: "TokenMeterDemo", targets: ["TokenMeterDemo"])
    ],
    targets: [
        .target(
            name: "TokenMeterKit"
        ),
        .executableTarget(
            name: "TokenMeterDemo",
            dependencies: ["TokenMeterKit"]
        ),
        .testTarget(
            name: "TokenMeterKitTests",
            dependencies: ["TokenMeterKit"]
        )
    ]
)
