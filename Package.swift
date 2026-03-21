// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AccessPulseiOS",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AccessPulseCore", targets: ["AccessPulseCore"]),
        .library(name: "AccessPulseAuditEngine", targets: ["AccessPulseAuditEngine"]),
        .library(name: "AccessPulseSyntaxRules", targets: ["AccessPulseSyntaxRules"]),
        .library(name: "AccessPulseUI", targets: ["AccessPulseUI"]),
        .library(name: "AccessPulseExamples", targets: ["AccessPulseExamples"]),
        .executable(name: "accesspulse", targets: ["AccessPulseCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", exact: "600.0.1")
    ],
    targets: [
        .target(
            name: "AccessPulseCore"
        ),
        .target(
            name: "AccessPulseAuditEngine",
            dependencies: ["AccessPulseCore", "AccessPulseSyntaxRules"]
        ),
        .target(
            name: "AccessPulseSyntaxRules",
            dependencies: [
                "AccessPulseCore",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ]
        ),
        .target(
            name: "AccessPulseUI",
            dependencies: ["AccessPulseCore"]
        ),
        .target(
            name: "AccessPulseExamples",
            dependencies: ["AccessPulseUI", "AccessPulseCore"]
        ),
        .executableTarget(
            name: "AccessPulseCLI",
            dependencies: ["AccessPulseAuditEngine", "AccessPulseCore"]
        ),
        .testTarget(
            name: "AccessPulseTests",
            dependencies: ["AccessPulseAuditEngine", "AccessPulseCore"]
        )
    ]
)
