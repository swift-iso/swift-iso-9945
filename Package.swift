// swift-tools-version: 6.4

import PackageDescription

let testHelperTargets: [Target] = [
    .executableTarget(
        name: "iso-9945-test-helper",
        dependencies: [],
        path: "Tests/Support/POSIX Helper"
    ),
    .executableTarget(
        name: "iso-9945-lock-helper",
        dependencies: [
            .target(name: "ISO 9945 Kernel")
        ],
        path: "Tests/Support/Lock Helper"
    ),
]

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
            name: "ISO 9945 Utility",
            targets: ["ISO 9945 Utility"]
        ),

        .library(
            name: "ISO 9945 Kernel Test Support",
            targets: ["ISO 9945 Kernel Test Support"]
        ),
        .library(
            name: "ISO 9945 Utility Coder",
            targets: ["ISO 9945 Utility Coder"]
        ),
    ],
    traits: [
        .trait(name: "Coder", description: "Coder integration for utility invocations")
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-carrier.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-loader-vocabulary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-string.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-clock.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-time.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-binary.git",
            branch: "main",
            traits: ["Serializer"]
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-space.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-terminal.git",
            branch: "main",
            traits: ["Error", "Input"]
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-error.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-random.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-path.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-system.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-memory.git",
            branch: "main",
            traits: ["Lock", "Map", "Shared", "Cursor"]
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-allocation.git",
            branch: "main",
            traits: ["MemorySmall", "MemoryAllocatorArena", "MemoryInline"]
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-ascii.git",
            branch: "main",
            traits: ["Parser", "Serializer"]
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-cpu.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-pair.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-iso/swift-iso-9899.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-checkpoint.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-coder.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-cursor.git", branch: "main"),
        .package(
            url: "https://github.com/swift-atoms/swift-parser.git",
            branch: "main",
            traits: [
                .trait(name: "Append", condition: .when(traits: ["Coder"])), .trait(name: "Either", condition: .when(traits: ["Coder"])), .trait(name: "Iterator", condition: .when(traits: ["Coder"])),
                .trait(name: "IteratorLeaves", condition: .when(traits: ["Coder"])), .trait(name: "Map", condition: .when(traits: ["Coder"])),
                .trait(name: "Product", condition: .when(traits: ["Coder"])), .trait(name: "Skip", condition: .when(traits: ["Coder"])),
            ]
        ),
        .package(url: "https://github.com/swift-atoms/swift-serializer.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "ISO 9945 Utility Coder",
            dependencies: [
                .target(name: "ISO 9945 Core"),
                .target(name: "ISO 9945 Utility"),
                .product(name: "Checkpoint", package: "swift-checkpoint", condition: .when(traits: ["Coder"])),
                .product(name: "Coder", package: "swift-coder", condition: .when(traits: ["Coder"])),
                .product(name: "Cursor", package: "swift-cursor", condition: .when(traits: ["Coder"])),
                .product(name: "Parser", package: "swift-parser", condition: .when(traits: ["Coder"])),
                .product(name: "Serializer", package: "swift-serializer", condition: .when(traits: ["Coder"])),
            ]
        ),
        .testTarget(
            name: "ISO 9945 Utility Coder Tests",
            dependencies: [
                .target(name: "ISO 9945 Utility Coder"),
                .target(name: "ISO 9945 Core"),
                .target(name: "ISO 9945 Utility"),
                .product(name: "Coder", package: "swift-coder", condition: .when(traits: ["Coder"])),
                .product(name: "Parser", package: "swift-parser", condition: .when(traits: ["Coder"])),
                .product(name: "Serializer", package: "swift-serializer", condition: .when(traits: ["Coder"])),
            ]
        ),

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
                .product(name: "Space", package: "swift-space"),
                .product(name: "CPU", package: "swift-cpu"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "System Primitives", package: "swift-system"),
            ]
        ),

        .target(
            name: "ISO 9945 Process Shims",
            dependencies: []
        ),
        .target(
            name: "ISO 9945 Shims",
            dependencies: []
        ),

        .target(
            name: "ISO 9945 Kernel File",
            dependencies: [
                .target(name: "ISO 9945 Core"),
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
                .target(name: "ISO 9945 Core"),
                .product(name: "String", package: "swift-string"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Lock",
            dependencies: [
                .target(name: "ISO 9945 Core"),
                .target(name: "ISO 9945 Kernel Clock"),
                .target(name: "ISO 9945 Kernel System"),
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
                .target(name: "ISO 9945 Core")
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Socket",
            dependencies: [
                .target(name: "ISO 9945 Core"),
                .target(name: "ISO 9945 Kernel File"),
                .target(name: "ISO 9945 Kernel Poll"),
                .target(name: "ISO 9945 Kernel Socket Address"),
                .product(name: "Pair", package: "swift-pair"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Memory",
            dependencies: [
                .target(name: "ISO 9945 Core"),
                .target(
                    name: "ISO 9945 Shims",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(name: "Memory", package: "swift-memory"),
                .product(
                    name: "Memory Allocation",
                    package: "swift-memory-allocation"
                ),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Signal",
            dependencies: [
                .target(name: "ISO 9945 Core")
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Process",
            dependencies: [
                .target(name: "ISO 9945 Core"),
                .target(
                    name: "ISO 9945 Process Shims",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(name: "Path", package: "swift-path"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Thread",
            dependencies: [
                .target(name: "ISO 9945 Core")
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Terminal",
            dependencies: [
                .target(name: "ISO 9945 Core"),
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
                .target(name: "ISO 9945 Core"),
                .product(name: "String", package: "swift-string"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Clock",
            dependencies: [
                .target(name: "ISO 9945 Core"),
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
                .target(name: "ISO 9945 Core"),
                .product(name: "Time", package: "swift-time"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel System",
            dependencies: [
                .target(name: "ISO 9945 Core"),
                .product(name: "System Primitives", package: "swift-system"),
                .product(name: "Random", package: "swift-random"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Memory", package: "swift-memory"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Identity",
            dependencies: [
                .target(name: "ISO 9945 Core"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Poll",
            dependencies: [
                .target(name: "ISO 9945 Core")
            ]
        ),

        .target(
            name: "ISO 9945 Glob",
            dependencies: [
                .target(name: "ISO 9945 Core"),
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
                .target(name: "ISO 9945 Core"),
                .target(name: "ISO 9945 Kernel File"),
                .target(name: "ISO 9945 Kernel Directory"),
                .target(name: "ISO 9945 Kernel Lock"),
                .target(name: "ISO 9945 Kernel Socket Address"),
                .target(name: "ISO 9945 Kernel Socket"),
                .target(name: "ISO 9945 Kernel Memory"),
                .target(name: "ISO 9945 Kernel Signal"),
                .target(name: "ISO 9945 Kernel Process"),
                .target(name: "ISO 9945 Kernel Thread"),
                .target(name: "ISO 9945 Kernel Terminal"),
                .target(name: "ISO 9945 Kernel Environment"),
                .target(name: "ISO 9945 Kernel Clock"),
                .target(name: "ISO 9945 Kernel Time"),
                .target(name: "ISO 9945 Kernel System"),
                .target(name: "ISO 9945 Kernel Poll"),
                .target(name: "ISO 9945 Kernel Identity"),
            ]
        ),

        .target(
            name: "ISO 9945 Loader",
            dependencies: [
                .target(name: "ISO 9945 Core"),
                .target(
                    name: "ISO 9945 Shims",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(name: "Loader Vocabulary", package: "swift-loader-vocabulary"),
            ]
        ),

        .target(
            name: "ISO 9945 Utility",
            dependencies: [
                .target(name: "ISO 9945 Core")
            ]
        ),

        .testTarget(
            name: "ISO 9945 Utility Tests",
            dependencies: [
                .target(name: "ISO 9945 Core"),
                .target(name: "ISO 9945 Utility"),
            ]
        ),

        .target(
            name: "ISO 9945 Kernel Test Support",
            dependencies: [
                .target(name: "ISO 9945 Kernel"),
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
                .target(name: "ISO 9945 Kernel"),
                .target(name: "ISO 9945 Glob"),
                .target(name: "ISO 9945 Loader"),
                .target(name: "ISO 9945 Kernel Test Support"),
                .product(name: "Loader Vocabulary", package: "swift-loader-vocabulary"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Path", package: "swift-path"),
                .product(name: "System Primitives", package: "swift-system"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Time", package: "swift-time"),
            ]
        ),
    ] + testHelperTargets,
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
        ]
}
