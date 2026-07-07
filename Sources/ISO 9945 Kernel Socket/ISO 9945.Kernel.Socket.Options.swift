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

// MARK: - POSIX socket options

extension ISO_9945.Kernel.Socket.Options {
    /// Set the socket to non-blocking mode.
    ///
    /// Equivalent to setting `O_NONBLOCK` after socket creation.
    public static let nonBlock = Self(rawValue: Int32(O_NONBLOCK))

    /// Set close-on-exec flag on the socket descriptor.
    ///
    /// Equivalent to setting `O_CLOEXEC` after socket creation.
    public static let closeOnExec = Self(rawValue: Int32(O_CLOEXEC))

    /// Non-blocking with close-on-exec (common for async I/O).
    public static let asyncDefault: Self = [.nonBlock, .closeOnExec]
}
