// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-iso-9945",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        // MARK: - Kernel (umbrella)
        .library(
            name: "ISO 9945 Kernel",
            targets: ["ISO 9945 Kernel"]
        ),

        // MARK: - Kernel Variants
        .library(
            name: "ISO 9945 Kernel File",
            targets: ["ISO 9945 Kernel File"]
        ),
        .library(
            name: "ISO 9945 Kernel Directory",
            targets: ["ISO 9945 Kernel Directory"]
        ),
        .library(
            name: "ISO 9945 Kernel Lock",
            targets: ["ISO 9945 Kernel Lock"]
        ),
        .library(
            name: "ISO 9945 Kernel Socket",
            targets: ["ISO 9945 Kernel Socket"]
        ),
        .library(
            name: "ISO 9945 Kernel Memory",
            targets: ["ISO 9945 Kernel Memory"]
        ),
        .library(
            name: "ISO 9945 Kernel Signal",
            targets: ["ISO 9945 Kernel Signal"]
        ),
        .library(
            name: "ISO 9945 Kernel Process",
            targets: ["ISO 9945 Kernel Process"]
        ),
        .library(
            name: "ISO 9945 Kernel Thread",
            targets: ["ISO 9945 Kernel Thread"]
        ),
        .library(
            name: "ISO 9945 Kernel Terminal",
            targets: ["ISO 9945 Kernel Terminal"]
        ),
        .library(
            name: "ISO 9945 Kernel Environment",
            targets: ["ISO 9945 Kernel Environment"]
        ),
        .library(
            name: "ISO 9945 Kernel System",
            targets: ["ISO 9945 Kernel System"]
        ),

        // MARK: - Loader
        .library(
            name: "ISO 9945 Loader",
            targets: ["ISO 9945 Loader"]
        ),

        // MARK: - Test Support
        .library(
            name: "ISO 9945 Kernel Test Support",
            targets: ["ISO 9945 Kernel Test Support"]
        )
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-algebra-primitives"),
        .package(path: "../../swift-primitives/swift-identity-primitives"),
        .package(path: "../../swift-primitives/swift-kernel-primitives"),
        .package(path: "../../swift-primitives/swift-loader-primitives"),
        .package(path: "../../swift-primitives/swift-string-primitives"),
        .package(path: "../../swift-primitives/swift-clock-primitives"),
        .package(path: "../../swift-primitives/swift-terminal-primitives"),
        .package(path: "../swift-iso-9899")
    ],
    targets: [
        // MARK: - Core (internal — not a published product)

        .target(
            name: "ISO 9945 Core",
            dependencies: [
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Kernel Descriptor Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Process Primitives", package: "swift-kernel-primitives"),
                .product(name: "Identity Primitives", package: "swift-identity-primitives"),
            ]
        ),

        // MARK: - C Shims

        .target(
            name: "CPOSIXProcessShim",
            dependencies: []
        ),
        .target(
            name: "CISO9945Shim",
            dependencies: []
        ),

        // MARK: - File

        .target(
            name: "ISO 9945 Kernel File",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel IO Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Permission Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Path Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Syscall Primitives", package: "swift-kernel-primitives"),
                .product(name: "Algebra Primitives", package: "swift-algebra-primitives"),
                .product(name: "String Primitives", package: "swift-string-primitives"),
                .product(name: "ISO 9899 Core", package: "swift-iso-9899")
            ]
        ),

        // MARK: - Directory

        .target(
            name: "ISO 9945 Kernel Directory",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "String Primitives", package: "swift-string-primitives"),
            ]
        ),

        // MARK: - Lock

        .target(
            name: "ISO 9945 Kernel Lock",
            dependencies: [
                "ISO 9945 Core",
                "ISO 9945 Kernel System",
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Clock Primitives", package: "swift-clock-primitives"),
            ]
        ),

        // MARK: - Socket

        .target(
            name: "ISO 9945 Kernel Socket",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "Kernel Socket Primitives", package: "swift-kernel-primitives"),
                .product(name: "Algebra Primitives", package: "swift-algebra-primitives"),
            ]
        ),

        // MARK: - Memory

        .target(
            name: "ISO 9945 Kernel Memory",
            dependencies: [
                "ISO 9945 Core",
                .target(name: "CISO9945Shim", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "Kernel Memory Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Signal

        .target(
            name: "ISO 9945 Kernel Signal",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "Kernel Process Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Syscall Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Process

        .target(
            name: "ISO 9945 Kernel Process",
            dependencies: [
                "ISO 9945 Core",
                .target(name: "CPOSIXProcessShim", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "Kernel Process Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Syscall Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Path Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Thread

        .target(
            name: "ISO 9945 Kernel Thread",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "Kernel Thread Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Terminal

        .target(
            name: "ISO 9945 Kernel Terminal",
            dependencies: [
                "ISO 9945 Core",
                .target(name: "CISO9945Shim", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "Kernel Terminal Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel IO Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Syscall Primitives", package: "swift-kernel-primitives"),
                .product(name: "Terminal Primitives", package: "swift-terminal-primitives"),
            ]
        ),

        // MARK: - Environment

        .target(
            name: "ISO 9945 Kernel Environment",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "Kernel Environment Primitives", package: "swift-kernel-primitives"),
                .product(name: "String Primitives", package: "swift-string-primitives"),
            ]
        ),

        // MARK: - System

        .target(
            name: "ISO 9945 Kernel System",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "Kernel System Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Time Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Clock Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Random Primitives", package: "swift-kernel-primitives"),
                .product(name: "Clock Primitives", package: "swift-clock-primitives"),
            ]
        ),

        // MARK: - Umbrella

        .target(
            name: "ISO 9945 Kernel",
            dependencies: [
                "ISO 9945 Core",
                "ISO 9945 Kernel File",
                "ISO 9945 Kernel Directory",
                "ISO 9945 Kernel Lock",
                "ISO 9945 Kernel Socket",
                "ISO 9945 Kernel Memory",
                "ISO 9945 Kernel Signal",
                "ISO 9945 Kernel Process",
                "ISO 9945 Kernel Thread",
                "ISO 9945 Kernel Terminal",
                "ISO 9945 Kernel Environment",
                "ISO 9945 Kernel System",
            ]
        ),

        // MARK: - Loader

        .target(
            name: "ISO 9945 Loader",
            dependencies: [
                "ISO 9945 Core",
                .target(name: "CISO9945Shim", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "Loader Primitives", package: "swift-loader-primitives")
            ]
        ),

        // MARK: - Test Helpers

        .executableTarget(
            name: "iso-9945-test-helper",
            dependencies: [],
            path: "Sources/CPOSIXTestHelper"
        ),
        .executableTarget(
            name: "iso-9945-lock-helper",
            dependencies: [
                "ISO 9945 Kernel"
            ],
            path: "Tests/Support/Lock Helper"
        ),

        // MARK: - Test Support

        .target(
            name: "ISO 9945 Kernel Test Support",
            dependencies: [
                "ISO 9945 Kernel",
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Kernel Descriptor Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Event Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel IO Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Path Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Environment Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Process Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Thread Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Primitives Test Support", package: "swift-kernel-primitives"),
                .product(name: "String Primitives", package: "swift-string-primitives")
            ],
            path: "Tests/Support",
            exclude: ["Lock Helper"]
        ),

        // MARK: - Tests

        .testTarget(
            name: "ISO 9945 Kernel Tests",
            dependencies: [
                "ISO 9945 Kernel",
                "ISO 9945 Kernel Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
