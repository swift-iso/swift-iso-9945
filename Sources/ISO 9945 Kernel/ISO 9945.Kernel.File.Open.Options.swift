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

@_spi(Syscall) public import Kernel_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
    internal import CLinuxShim
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX File Open Options

extension ISO_9945.Kernel.File.Open {
    /// Options that modify file opening behavior on POSIX systems.
    ///
    /// The raw value is the POSIX open flag directly (O_CREAT, O_TRUNC, etc.).
    /// Multiple options can be combined using bitwise OR.
    ///
    /// ## Usage
    /// ```swift
    /// // Create file if it doesn't exist
    /// let fd = try Kernel.File.Open.open(path: view, mode: .write, options: .create, ...)
    ///
    /// // Create and truncate
    /// let fd = try Kernel.File.Open.open(path: view, mode: .write, options: [.create, .truncate], ...)
    /// ```
    public struct Options: OptionSet, Sendable, Hashable {
        /// The POSIX open flags.
        public let rawValue: Int32

        /// Creates options from raw POSIX flags.
        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Standard Options

extension ISO_9945.Kernel.File.Open.Options {
    /// Creates the file if it does not exist (O_CREAT).
    public static let create = Self(rawValue: O_CREAT)

    /// Truncates the file to zero length if it exists (O_TRUNC).
    public static let truncate = Self(rawValue: O_TRUNC)

    /// Positions all writes at the end of file (O_APPEND).
    public static let append = Self(rawValue: O_APPEND)

    /// Fails if the file already exists (O_EXCL).
    public static let exclusive = Self(rawValue: O_EXCL)

    /// Closes the file descriptor on exec (O_CLOEXEC).
    public static let execClose = Self(rawValue: O_CLOEXEC)

    /// Disables blocking on the file descriptor (O_NONBLOCK).
    public static let nonBlocking = Self(rawValue: O_NONBLOCK)

    /// Does not follow symlinks when opening (O_NOFOLLOW).
    public static let noFollow = Self(rawValue: O_NOFOLLOW)

    #if os(Linux)
    /// Requests direct I/O, bypassing page cache (O_DIRECT).
    ///
    /// Linux-specific. Not available on Darwin.
    public static let direct = Self(rawValue: O_DIRECT)
    #endif
}

// MARK: - Darwin-specific Options

#if canImport(Darwin)
extension ISO_9945.Kernel.File.Open.Options {
    /// Disables caching (F_NOCACHE).
    ///
    /// Darwin-specific. Applied via `fcntl` after open.
    /// This flag is stored internally and applied post-open.
    public static let noCache = Self(rawValue: 1 << 30)  // Internal flag, not passed to open()

    /// Returns true if noCache was requested.
    @usableFromInline
    internal var needsNoCache: Bool {
        contains(.noCache)
    }

    /// Returns the flags to pass to open(), excluding internal flags.
    @usableFromInline
    internal var openFlags: Int32 {
        rawValue & ~(1 << 30)
    }
}
#endif
