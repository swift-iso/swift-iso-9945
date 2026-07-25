// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#endif

// MARK: - TestExecutable

/// Locates a test-support executable that the build emits alongside the running
/// test binary.
///
/// ## Why this derives the path instead of naming a build directory
///
/// The previous resolution strategy hardcoded `.build/debug/<name>` relative to
/// the package root. That works **only** in a debug SwiftPM build, and it fails
/// in a way that is hard to read: when the path misses, resolution fell through
/// to a bare executable name, which was handed to `posix_spawn` with an empty
/// `envp`. `posix_spawn` does not search `PATH` (that is `posix_spawnp`), and an
/// empty environment has no `PATH` to search regardless — so the spawn failed
/// with a bare `ENOENT` (`posix(2)`), reported as `spawn failed`, with nothing
/// pointing at the real cause.
///
/// Deriving from the **running test binary's own directory** removes the
/// build-layout knowledge entirely: the support executable is emitted beside the
/// test binary in every layout we build. Walking a few levels upward covers the
/// nesting differences between them:
///
/// - SwiftPM Linux: `.build/<triple>/<config>/` — helper is a sibling.
/// - SwiftPM macOS: `.build/<triple>/<config>/<Pkg>PackageTests.xctest/Contents/MacOS/`
///   — the bundle nests the binary three levels below the products directory.
/// - xcodebuild: `.build/out/Products/<Config>-<platform>-<arch>/` — sibling.
///
/// So the same code works under debug, release, SwiftPM and xcodebuild without
/// enumerating any of them.
///
/// A missing helper now returns `nil` rather than a bare name, so callers fail
/// with a message that names the executable instead of an opaque `ENOENT`.
enum TestExecutable {
    /// Thrown when a support executable cannot be located.
    ///
    /// Naming the executable is the point: the previous strategy failed as a bare
    /// `ENOENT` from `posix_spawn`, which said nothing about *which* file was
    /// missing or why.
    struct NotFound: Swift.Error, CustomStringConvertible {
        let name: Swift.String

        var description: Swift.String {
            """
            test-support executable '\(name)' not found beside the running test \
            binary. Build it (it is an executableTarget in this package) or set an \
            explicit override environment variable.
            """
        }
    }

    /// Maximum number of directory levels to ascend from the test binary.
    ///
    /// Three covers the deepest layout we build (the macOS `.xctest` bundle);
    /// five leaves headroom without ascending far enough to match an unrelated
    /// executable higher up the tree.
    private static let maximumAscent = 5

    /// Resolves `name` to an executable path, or `nil` when it cannot be found.
    ///
    /// - Parameters:
    ///   - name: The support executable's file name, e.g. `iso-9945-lock-helper`.
    ///   - overrides: Environment variables consulted first, in order. These stay
    ///     supported so CI can point at a prebuilt helper explicitly.
    static func path(_ name: Swift.String, overrides: [Swift.String] = []) -> Swift.String? {
        for variable in overrides {
            if let value = unsafe getenv(variable) {
                let candidate = unsafe Swift.String(cString: value)
                if isExecutable(candidate) {
                    return candidate
                }
            }
        }

        guard var directory = runningExecutableDirectory() else { return nil }

        for _ in 0..<maximumAscent {
            let candidate = "\(directory)/\(name)"
            if isExecutable(candidate) {
                return candidate
            }
            guard
                let separator = directory.lastIndex(of: "/"),
                separator != directory.startIndex
            else { break }
            directory = Swift.String(directory[..<separator])
        }

        return nil
    }

    /// The directory containing the currently running executable.
    private static func runningExecutableDirectory() -> Swift.String? {
        guard let executable = runningImagePath() else { return nil }
        guard let separator = executable.lastIndex(of: "/") else { return nil }
        return Swift.String(executable[..<separator])
    }

    #if canImport(Darwin)
        /// A marker whose address identifies the binary image containing this code.
        ///
        /// Only its address is used; it is never called.
        private static let imageMarker: @convention(c) () -> Void = {}
    #endif

    /// The absolute path of the binary image containing this code.
    ///
    /// ## Why this is not "the running executable"
    ///
    /// The two platforms need different questions asked, and the difference is
    /// load-bearing rather than cosmetic:
    ///
    /// - **Darwin**: under `swift test` the *main executable* is the `xctest`
    ///   tool — the test bundle is **loaded**, not exec'd. So a main-executable
    ///   query (`_NSGetExecutablePath`, or `argv[0]`) reports the tool, which
    ///   lives in the toolchain and has no helper anywhere near it. `dladdr` on
    ///   the address of our own code reports the **image containing that code** —
    ///   the test binary inside `…/PackageTests.xctest/Contents/MacOS/` — which is
    ///   what we need.
    /// - **Linux**: there is no bundle indirection; the test binary *is* the main
    ///   executable, so `/proc/self/exe` is both correct and simpler. (`dladdr`
    ///   and `Dl_info` are not exposed by the `Glibc` module.)
    ///
    /// Anchoring to the image containing this code has a second benefit: it points
    /// at the **current configuration's** products directory, so it cannot pick up
    /// a stale sibling from a different configuration — the exact contamination
    /// that made an earlier release-mode probe of this defect falsely pass.
    private static func runningImagePath() -> Swift.String? {
        #if canImport(Darwin)
            var info = unsafe Dl_info()
            let address: UnsafeRawPointer = unsafe unsafeBitCast(
                Self.imageMarker,
                to: UnsafeRawPointer.self
            )
            guard unsafe dladdr(address, &info) != 0 else { return nil }
            guard let name = unsafe info.dli_fname else { return nil }
            return unsafe Swift.String(cString: name)
        #elseif canImport(Glibc)
            var buffer = [CChar](repeating: 0, count: 4096)
            let written = unsafe readlink("/proc/self/exe", &buffer, buffer.count - 1)
            guard written > 0 else { return nil }
            buffer[written] = 0
            return Self.string(fromNulTerminated: buffer)
        #else
            return nil
        #endif
    }

    /// Decodes a NUL-terminated `CChar` buffer.
    ///
    /// Goes through the pointer overload of `String.init(cString:)`; the `[CChar]`
    /// overload is deprecated in favour of `String(decoding:as:)`, which would
    /// require truncating the NUL and rebinding to `UInt8` by hand.
    private static func string(fromNulTerminated buffer: [CChar]) -> Swift.String {
        unsafe buffer.withUnsafeBufferPointer { pointer in
            unsafe Swift.String(cString: pointer.baseAddress!)
        }
    }

    /// Whether `path` names a file the current process may execute.
    private static func isExecutable(_ path: Swift.String) -> Bool {
        unsafe path.withCString { cPath in
            unsafe access(cPath, X_OK) == 0
        }
    }
}
