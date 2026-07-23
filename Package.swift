// swift-tools-version: 6.3.3

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

        // MARK: - Core (consumed directly post Cycle 18 absorption)
        .library(
            name: "ISO 9945 Core",
            targets: ["ISO 9945 Core"]
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
            name: "ISO 9945 Kernel Socket Address",
            targets: ["ISO 9945 Kernel Socket Address"]
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
            name: "ISO 9945 Kernel Clock",
            targets: ["ISO 9945 Kernel Clock"]
        ),
        .library(
            name: "ISO 9945 Kernel Time",
            targets: ["ISO 9945 Kernel Time"]
        ),
        .library(
            name: "ISO 9945 Kernel System",
            targets: ["ISO 9945 Kernel System"]
        ),

        // MARK: - Identity
        .library(
            name: "ISO 9945 Kernel Identity",
            targets: ["ISO 9945 Kernel Identity"]
        ),

        // MARK: - Poll
        .library(
            name: "ISO 9945 Kernel Poll",
            targets: ["ISO 9945 Kernel Poll"]
        ),

        // MARK: - Glob
        .library(
            name: "ISO 9945 Glob",
            targets: ["ISO 9945 Glob"]
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
        .package(url: "https://github.com/swift-primitives/swift-carrier-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-tagged-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-loader-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-string-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-clock-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-time-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-binary-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-dimension-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-equation-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-terminal-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-error-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-random-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-path-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-system-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-allocation-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-lock-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-shared-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-map-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-ascii-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-cpu-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-cardinal-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-either-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-pair-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-iso/swift-iso-9899.git", branch: "main")
    ],
    targets: [
        // MARK: - Core (internal — not a published product)

        .target(
            name: "ISO 9945 Core",
            dependencies: [
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Allocation Primitives", package: "swift-memory-allocation-primitives"),
                .product(name: "Path Primitives", package: "swift-path-primitives"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
                .product(name: "Carrier Primitives", package: "swift-carrier-primitives"),
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
                .product(name: "Time Primitives", package: "swift-time-primitives"),
                .product(name: "Binary Primitives", package: "swift-binary-primitives"),
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives"),
                .product(name: "Equation Primitives", package: "swift-equation-primitives"),
                .product(name: "CPU Primitives", package: "swift-cpu-primitives"),
                .product(name: "Cardinal Primitives", package: "swift-cardinal-primitives"),
                .product(name: "ASCII Primitives", package: "swift-ascii-primitives"),
                .product(name: "System Primitives", package: "swift-system-primitives"),
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
                .product(name: "Path Primitives", package: "swift-path-primitives"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
                .product(name: "Pair Primitives", package: "swift-pair-primitives"),
                .product(name: "String Primitives", package: "swift-string-primitives"),
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
                .product(name: "ISO 9899 Core", package: "swift-iso-9899")
            ]
        ),

        // MARK: - Directory

        .target(
            name: "ISO 9945 Kernel Directory",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "String Primitives", package: "swift-string-primitives"),
            ]
        ),

        // MARK: - Lock

        .target(
            name: "ISO 9945 Kernel Lock",
            dependencies: [
                "ISO 9945 Core",
                "ISO 9945 Kernel Clock",
                "ISO 9945 Kernel System",
                .product(name: "Clock Primitives", package: "swift-clock-primitives"),
                .product(name: "Memory Allocation Primitives", package: "swift-memory-allocation-primitives"),
            ]
        ),

        // MARK: - Socket Address

        .target(
            name: "ISO 9945 Kernel Socket Address",
            dependencies: [
                "ISO 9945 Core",
            ]
        ),

        // MARK: - Socket

        .target(
            name: "ISO 9945 Kernel Socket",
            dependencies: [
                "ISO 9945 Core",
                "ISO 9945 Kernel File",
                "ISO 9945 Kernel Poll",
                "ISO 9945 Kernel Socket Address",
                .product(name: "Pair Primitives", package: "swift-pair-primitives"),
            ]
        ),

        // MARK: - Memory

        .target(
            name: "ISO 9945 Kernel Memory",
            dependencies: [
                "ISO 9945 Core",
                .target(name: "CISO9945Shim", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Allocation Primitives", package: "swift-memory-allocation-primitives"),
                .product(name: "Memory Lock Primitives", package: "swift-memory-lock-primitives"),
                .product(name: "Memory Shared Primitives", package: "swift-memory-shared-primitives"),
                .product(name: "Memory Map Primitives", package: "swift-memory-map-primitives"),
            ]
        ),

        // MARK: - Signal

        .target(
            name: "ISO 9945 Kernel Signal",
            dependencies: [
                "ISO 9945 Core",
            ]
        ),

        // MARK: - Process

        .target(
            name: "ISO 9945 Kernel Process",
            dependencies: [
                "ISO 9945 Core",
                .target(name: "CPOSIXProcessShim", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "Path Primitives", package: "swift-path-primitives"),
            ]
        ),

        // MARK: - Thread

        .target(
            name: "ISO 9945 Kernel Thread",
            dependencies: [
                "ISO 9945 Core",
            ]
        ),

        // MARK: - Terminal

        .target(
            name: "ISO 9945 Kernel Terminal",
            dependencies: [
                "ISO 9945 Core",
                .target(name: "CISO9945Shim", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "Terminal Primitives", package: "swift-terminal-primitives"),
            ]
        ),

        // MARK: - Environment

        .target(
            name: "ISO 9945 Kernel Environment",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "String Primitives", package: "swift-string-primitives"),
            ]
        ),

        // MARK: - Clock

        .target(
            name: "ISO 9945 Kernel Clock",
            dependencies: [
                "ISO 9945 Core",
                .target(name: "CISO9945Shim", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "Clock Primitives", package: "swift-clock-primitives"),
            ]
        ),

        // MARK: - Time

        .target(
            name: "ISO 9945 Kernel Time",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "Time Primitives", package: "swift-time-primitives"),
            ]
        ),

        // MARK: - System

        .target(
            name: "ISO 9945 Kernel System",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "System Primitives", package: "swift-system-primitives"),
                .product(name: "Random Primitives", package: "swift-random-primitives"),
            ]
        ),

        // MARK: - Identity

        .target(
            name: "ISO 9945 Kernel Identity",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
            ]
        ),

        // MARK: - Poll

        .target(
            name: "ISO 9945 Kernel Poll",
            dependencies: [
                "ISO 9945 Core",
            ]
        ),

        // MARK: - Glob

        .target(
            name: "ISO 9945 Glob",
            dependencies: [
                "ISO 9945 Core",
                .target(name: "CISO9945Shim", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "Path Primitives", package: "swift-path-primitives"),
                .product(name: "ASCII Primitives", package: "swift-ascii-primitives"),
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
                "ISO 9945 Kernel Socket Address",
                "ISO 9945 Kernel Socket",
                "ISO 9945 Kernel Memory",
                "ISO 9945 Kernel Signal",
                "ISO 9945 Kernel Process",
                "ISO 9945 Kernel Thread",
                "ISO 9945 Kernel Terminal",
                "ISO 9945 Kernel Environment",
                "ISO 9945 Kernel Clock",
                "ISO 9945 Kernel Time",
                "ISO 9945 Kernel System",
                "ISO 9945 Kernel Poll",
                "ISO 9945 Kernel Identity",
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
                .product(name: "Cardinal Primitives Test Support", package: "swift-cardinal-primitives"),
                .product(name: "Path Primitives", package: "swift-path-primitives"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
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
                "ISO 9945 Glob",
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
