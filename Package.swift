// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-posix-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "POSIX Primitives",
            targets: ["POSIX Primitives"]
        ),
        .library(
            name: "POSIX Kernel Primitives",
            targets: ["POSIX Kernel Primitives"]
        ),
        .library(
            name: "POSIX Loader Primitives",
            targets: ["POSIX Loader Primitives"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-kernel-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-loader-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-test-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-foundations/swift-testing-extras.git", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "POSIX Primitives",
            dependencies: []
        ),
        .target(
            name: "CPOSIXProcessShim",
            dependencies: []
        ),
        .target(
            name: "POSIX Kernel Primitives",
            dependencies: [
                .target(name: "POSIX Primitives"),
                .target(name: "CPOSIXProcessShim", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
            ]
        ),
        .target(
            name: "POSIX Loader Primitives",
            dependencies: [
                .target(name: "POSIX Primitives"),
                .product(name: "Loader Primitives", package: "swift-loader-primitives"),
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
            ],
            path: "Sources/POSIX Loader Primitives"
        ),
        .executableTarget(
            name: "posix-test-helper",
            dependencies: [],
            path: "Sources/CPOSIXTestHelper"
        ),
        .testTarget(
            name: "POSIX Kernel Primitives Tests",
            dependencies: [
                "POSIX Kernel Primitives",
                "posix-test-helper",
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
                .product(name: "Test Primitives", package: "swift-test-primitives"),
                .product(name: "Testing Extras", package: "swift-testing-extras"),
            ],
            path: "Tests/POSIX Kernel Primitives Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
