// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "loundrycode",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(name: "LoundryCore", targets: ["LoundryCore"]),
        .library(name: "LoundryEnvironment", targets: ["LoundryEnvironment"]),
        .library(name: "LoundryModels", targets: ["LoundryModels"])
    ],
    targets: [
        .target(name: "LoundryModels"),
        .target(name: "LoundryEnvironment", dependencies: ["LoundryModels"]),
        .target(name: "LoundryCore", dependencies: ["LoundryEnvironment", "LoundryModels"]),
        .testTarget(name: "LoundryCoreTests", dependencies: ["LoundryCore"]),
        .testTarget(name: "LoundryEnvironmentTests", dependencies: ["LoundryEnvironment"])
    ]
)
