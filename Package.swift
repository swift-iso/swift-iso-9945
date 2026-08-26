// swift-tools-version: 6.4

import PackageDescription

#if os(Windows)
    let testHelperTargets: [Target] = []
#else
    let testHelperTargets: [Target] = [
        .executableTarget(
            name: "iso-9945-test-helper",
            dependencies: [],
            path: "Tests/Support/POSIX Helper"
        ),
        .executableTarget(
            name: "iso-9945-lock-helper",
            dependencies: [
                "ISO 9945 Kernel"
            ],
            path: "Tests/Support/Lock Helper"
        ),
    ]
#endif

let package = Package(
    name: "swift-iso-9945",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [

        .library(
            name: "ISO 9945 Kernel",
            targets: ["ISO 9945 Kernel"]
        ),

        .library(
            name: "ISO 9945 Core",
            targets: ["ISO 9945 Core"]
        ),

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

        .library(
            name: "ISO 9945 Kernel Identity",
            targets: ["ISO 9945 Kernel Identity"]
        ),

        .library(
            name: "ISO 9945 Kernel Poll",
            targets: ["ISO 9945 Kernel Poll"]
        ),

        .library(
            name: "ISO 9945 Glob",
            targets: ["ISO 9945 Glob"]
        ),

        .library(
            name: "ISO 9945 Loader",
            targets: ["ISO 9945 Loader"]
        ),

        .library(
            name: "ISO 9945 Kernel Test Support",
            targets: ["ISO 9945 Kernel Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-carrier.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-loader.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-string.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-clock.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-time.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-binary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-dimension.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-equation.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-terminal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-error.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-random.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-path.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-system.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-allocation.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-lock.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-shared.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-map.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cpu.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-pair.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-iso/swift-iso-9899.git", branch: "main"),
    ],
    targets: [

        .target(
            name: "ISO 9945 Core",
            dependencies: [
                .product(name: "Memory", package: "swift-memory"),
                .product(
                    name: "Memory Allocation",
                    package: "swift-memory-allocation"
                ),
                .product(name: "Path", package: "swift-path"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Carrier", package: "swift-carrier"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Time", package: "swift-time"),
                .product(name: "Binary", package: "swift-binary"),
                .product(name: "Dimension", package: "swift-dimension"),
                .product(name: "Equation", package: "swift-equation"),
                .product(name: "CPU", package: "swift-cpu"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "System", package: "swift-system"),
            ]
        ),

        .target(
            name: "POSIX Process Shims",
            dependencies: []
        ),
        .target(
            name: "ISO 9945 Shims",
            dependencies: []
        ),

        .target(
            name: "ISO 9945 Kernel File",
            dependencies: [
                "ISO 9945 Core",
                .target(
                    name: "ISO 9945 Shims",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(name: "Path", package: "swift-path"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Pair", package: "swift-pair"),
                .product(name: "String", package: "swift-string"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "ISO 9899 Core", package: "swift-iso-9899"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Directory",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "String", package: "swift-string"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Lock",
            dependencies: [
                "ISO 9945 Core",
                "ISO 9945 Kernel Clock",
                "ISO 9945 Kernel System",
                .product(name: "Clock", package: "swift-clock"),
                .product(
                    name: "Memory Allocation",
                    package: "swift-memory-allocation"
                ),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Socket Address",
            dependencies: [
                "ISO 9945 Core"
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Socket",
            dependencies: [
                "ISO 9945 Core",
                "ISO 9945 Kernel File",
                "ISO 9945 Kernel Poll",
                "ISO 9945 Kernel Socket Address",
                .product(name: "Pair", package: "swift-pair"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Memory",
            dependencies: [
                "ISO 9945 Core",
                .target(
                    name: "ISO 9945 Shims",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(name: "Memory", package: "swift-memory"),
                .product(
                    name: "Memory Allocation",
                    package: "swift-memory-allocation"
                ),
                .product(name: "Memory Lock", package: "swift-memory-lock"),
                .product(
                    name: "Memory Shared",
                    package: "swift-memory-shared"
                ),
                .product(name: "Memory Map", package: "swift-memory-map"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Signal",
            dependencies: [
                "ISO 9945 Core"
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Process",
            dependencies: [
                "ISO 9945 Core",
                .target(
                    name: "POSIX Process Shims",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(name: "Path", package: "swift-path"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Thread",
            dependencies: [
                "ISO 9945 Core"
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Terminal",
            dependencies: [
                "ISO 9945 Core",
                .target(
                    name: "ISO 9945 Shims",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(name: "Terminal", package: "swift-terminal"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Environment",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "String", package: "swift-string"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Clock",
            dependencies: [
                "ISO 9945 Core",
                .target(
                    name: "ISO 9945 Shims",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(name: "Clock", package: "swift-clock"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Time",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "Time", package: "swift-time"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel System",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "System", package: "swift-system"),
                .product(name: "Random", package: "swift-random"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Identity",
            dependencies: [
                "ISO 9945 Core",
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Poll",
            dependencies: [
                "ISO 9945 Core"
            ]
        ),

        .target(
            name: "ISO 9945 Glob",
            dependencies: [
                "ISO 9945 Core",
                .target(
                    name: "ISO 9945 Shims",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(name: "Path", package: "swift-path"),
                .product(name: "ASCII", package: "swift-ascii"),
            ]
        ),

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

        .target(
            name: "ISO 9945 Loader",
            dependencies: [
                "ISO 9945 Core",
                .target(
                    name: "ISO 9945 Shims",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(name: "Loader", package: "swift-loader"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Test Support",
            dependencies: [
                "ISO 9945 Kernel",
                .product(
                    name: "Cardinal Test Support",
                    package: "swift-cardinal"
                ),
                .product(name: "Path", package: "swift-path"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "String", package: "swift-string"),
            ],
            path: "Tests/Support",
            exclude: ["Lock Helper", "POSIX Helper"]
        ),

        .testTarget(
            name: "ISO 9945 Kernel Tests",
            dependencies: [
                "ISO 9945 Kernel",
                "ISO 9945 Glob",
                "ISO 9945 Kernel Test Support",
            ]
        ),
    ] + testHelperTargets,
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
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
