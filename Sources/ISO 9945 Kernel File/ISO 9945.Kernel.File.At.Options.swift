// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File.At {
    /// Path resolution flags (AT_* constants).
    ///
    /// Controls how *at() syscall variants resolve paths relative to
    /// directory file descriptors.
    public struct Options: OptionSet, Sendable {
        /// The platform path resolution flags.
        public let rawValue: Int32

        /// Creates options from raw platform flags.
        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - POSIX AT_* Constants

extension ISO_9945.Kernel.File.At.Options {
    /// Do not follow symbolic links (AT_SYMLINK_NOFOLLOW).
    public static let noFollow = Self(rawValue: Int32(AT_SYMLINK_NOFOLLOW))

    /// Follow symbolic links (AT_SYMLINK_FOLLOW).
    public static let symlinkFollow = Self(rawValue: Int32(AT_SYMLINK_FOLLOW))

    /// Remove directory instead of file (AT_REMOVEDIR).
    public static let removeDirectory = Self(rawValue: Int32(AT_REMOVEDIR))
}
