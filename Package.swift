// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-iso-9945",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
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
        ),
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-kernel-primitives"),
        .package(path: "../../swift-primitives/swift-loader-primitives"),
        .package(path: "../../swift-primitives/swift-string-primitives"),
        .package(path: "../../swift-primitives/swift-test-primitives"),
        .package(path: "../../swift-foundations/swift-testing-extras"),
    ],
    targets: [
        .target(
            name: "ISO 9945",
            dependencies: [],
            path: "Sources/ISO 9945"
        ),
        .target(
            name: "CPOSIXProcessShim",
            dependencies: []
        ),
        .target(
            name: "ISO 9945 Kernel",
            dependencies: [
                .target(name: "ISO 9945"),
                .target(name: "CPOSIXProcessShim", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
            ],
            path: "Sources/ISO 9945 Kernel"
        ),
        .target(
            name: "ISO 9945 Loader",
            dependencies: [
                .target(name: "ISO 9945"),
                .product(name: "Loader Primitives", package: "swift-loader-primitives"),
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
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
                "ISO 9945 Kernel",
            ],
            path: "Tests/Support/Lock Helper"
        ),
        .target(
            name: "ISO 9945 Kernel Test Support",
            dependencies: [
                "ISO 9945 Kernel",
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
                .product(name: "String Primitives", package: "swift-string-primitives"),
            ],
            path: "Tests/Support",
            exclude: ["Lock Helper"]
        ),
        .testTarget(
            name: "ISO 9945 Kernel Tests",
            dependencies: [
                "ISO 9945 Kernel",
                "iso-9945-test-helper",
                "iso-9945-lock-helper",
                "ISO 9945 Kernel Test Support",
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
                .product(name: "Test Primitives", package: "swift-test-primitives"),
                .product(name: "Testing Extras", package: "swift-testing-extras"),
            ],
            path: "Tests/ISO 9945 Kernel Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
        .strictMemorySafety(),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
