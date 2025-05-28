// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SpiderSolitaireApp",
    platforms: [
        .visionOS(.v1),
        .macOS(.v14)
    ],
    products: [
        .executable(name: "SpiderSolitaireApp", targets: ["SpiderSolitaireApp"])
    ],
    targets: [
        .executableTarget(
            name: "SpiderSolitaireApp",
            path: "Sources/SpiderSolitaireApp"
        )
    ]
)
