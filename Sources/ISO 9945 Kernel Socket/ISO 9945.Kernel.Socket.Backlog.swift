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

// MARK: - POSIX socket backlog

extension ISO_9945.Kernel.Socket.Backlog {
    /// System maximum backlog.
    ///
    /// Uses `SOMAXCONN` which typically maps to the system's maximum
    /// allowed backlog value.
    public static var max: ISO_9945.Kernel.Socket.Backlog {
        #if canImport(Darwin)
            ISO_9945.Kernel.Socket.Backlog(Darwin.SOMAXCONN)
        #elseif canImport(Musl)
            ISO_9945.Kernel.Socket.Backlog(Musl.SOMAXCONN)
        #elseif canImport(Glibc)
            ISO_9945.Kernel.Socket.Backlog(Glibc.SOMAXCONN)
        #endif
    }
}
