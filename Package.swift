// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "copyToast",
    platforms: [.macOS("15.4")],
    targets: [
        .target(name: "CopyToastCore"),
        .executableTarget(name: "copyToast", dependencies: ["CopyToastCore"]),
        .testTarget(name: "CopyToastCoreTests", dependencies: ["CopyToastCore"]),
    ]
)
