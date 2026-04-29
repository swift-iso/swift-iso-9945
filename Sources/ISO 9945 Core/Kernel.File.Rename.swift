// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


extension Kernel.File {
    /// Atomic rename operations.
    ///
    /// Provides cross-platform atomic rename operations with options
    /// like "no clobber" (fail if destination exists).
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.File.Rename`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.File.Rename`)
    public enum Rename {}
}

// MARK: - Error Type

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD)
    extension Kernel.File.Rename {
        /// Errors from rename operations.
        public enum Error: Swift.Error, Sendable, Equatable, Hashable {
            /// Destination already exists (no-clobber mode).
            case exists

            /// Operation not supported by filesystem or kernel.
            case notSupported

            /// Permission denied.
            case permission(Error_Primitives.Error.Code)

            /// Platform-specific error.
            case platform(Error_Primitives.Error.Code)
        }
    }

    extension Kernel.File.Rename.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .exists:
                return "rename failed: destination exists"
            case .notSupported:
                return "rename operation not supported"
            case .permission(let code):
                return "rename permission denied (\(code))"
            case .platform(let code):
                return "rename failed (\(code))"
            }
        }
    }

#endif
