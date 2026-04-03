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
        .library(
            name: "ISO 9945",
            targets: ["ISO 9945"]
        ),
        .library(
            name: "ISO 9945 Kernel",
            targets: ["ISO 9945 Kernel"]
        ),
        .library(
            name: "ISO 9945 Loader",
            targets: ["ISO 9945 Loader"]
        ),
        .library(
            name: "ISO 9945 Kernel Test Support",
            targets: ["ISO 9945 Kernel Test Support"]
        )
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-algebra-primitives"),
        .package(path: "../../swift-primitives/swift-kernel-primitives"),
        .package(path: "../../swift-primitives/swift-loader-primitives"),
        .package(path: "../../swift-primitives/swift-string-primitives"),
        .package(path: "../../swift-primitives/swift-clock-primitives"),
        .package(path: "../../swift-primitives/swift-terminal-primitives"),
        .package(path: "../../swift-foundations/swift-ascii")
    ],
    targets: [
        .target(
            name: "ISO 9945",
            dependencies: [],
            path: "Sources/ISO 9945"
        ),
        .target(
            name: "ISO 9945 ABI",
            dependencies: [],
            path: "Sources/ISO 9945 ABI"
        ),
        .target(
            name: "CPOSIXProcessShim",
            dependencies: []
        ),
        .target(
            name: "ISO 9945 Kernel",
            dependencies: [
                .target(name: "ISO 9945"),
                .target(name: "ISO 9945 ABI"),
                .target(name: "CPOSIXProcessShim", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "Algebra Primitives", package: "swift-algebra-primitives"),
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
                .product(name: "Clock Primitives", package: "swift-clock-primitives"),
                .product(name: "Terminal Primitives", package: "swift-terminal-primitives"),
                .product(name: "ASCII", package: "swift-ascii")
            ],
            path: "Sources/ISO 9945 Kernel"
        ),
        .target(
            name: "ISO 9945 Loader",
            dependencies: [
                .target(name: "ISO 9945"),
                .target(name: "ISO 9945 ABI"),
                .product(name: "Loader Primitives", package: "swift-loader-primitives"),
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives")
            ],
            path: "Sources/ISO 9945 Loader"
        ),
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
        .target(
            name: "ISO 9945 Kernel Test Support",
            dependencies: [
                "ISO 9945 Kernel",
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Primitives Test Support", package: "swift-kernel-primitives"),
                .product(name: "String Primitives", package: "swift-string-primitives")
            ],
            path: "Tests/Support",
            exclude: ["Lock Helper"]
        ),
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
