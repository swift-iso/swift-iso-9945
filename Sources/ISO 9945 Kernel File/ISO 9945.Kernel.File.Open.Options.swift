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
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX Standard Open Options

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
}
