// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ZoronBitrateBooster",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ZoronBitrateBooster",
            type: .dynamic,
            targets: ["ZoronBitrateBooster"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ZoronBitrateBooster",
            dependencies: [],
            path: "Sources/ZoronBitrateBooster",
            resources: []
        )
    ]
)
