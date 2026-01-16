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

// MARK: - POSIX-specific options

extension Kernel.File.Open.Options {
    /// Disables blocking on the file descriptor (O_NONBLOCK).
    ///
    /// POSIX-specific option for non-blocking I/O.
    public static let nonBlocking = Self(rawValue: 1 << 5)

    /// Disables caching (macOS F_NOCACHE).
    ///
    /// On macOS, this is applied via fcntl after open.
    /// On other platforms, this has no effect.
    public static let noCache = Self(rawValue: 1 << 7)
}

// MARK: - POSIX file open options conversion

extension Kernel.File.Open.Options {
    /// Converts the options to POSIX open flags.
    internal var posixFlags: Int32 {
        var flags: Int32 = 0

        if contains(.create) {
            flags |= O_CREAT
        }
        if contains(.truncate) {
            flags |= O_TRUNC
        }
        if contains(.append) {
            flags |= O_APPEND
        }
        if contains(.exclusive) {
            flags |= O_EXCL
        }
        if contains(.execClose) {
            flags |= O_CLOEXEC
        }
        if contains(.nonBlocking) {
            flags |= O_NONBLOCK
        }
        #if os(Linux)
        if contains(.direct) {
            flags |= O_DIRECT
        }
        #endif
        if contains(.noFollow) {
            flags |= O_NOFOLLOW
        }

        return flags
    }
}
