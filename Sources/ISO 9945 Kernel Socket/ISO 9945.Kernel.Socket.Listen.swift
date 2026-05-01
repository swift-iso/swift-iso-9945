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

@_spi(Syscall) public import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket {
    /// Socket listen namespace.
    public enum Listen {}
}

// MARK: - Listen typed (Phase 1.5)
//
// Typed Phase-1.5 form re-added in Wave 4c-Socket Main (2026-05-01) per
// [PLAT-ARCH-005] three-tier chain (Prerequisite II).

extension ISO_9945.Kernel.Socket.Listen {
    /// Marks a typed socket descriptor as a passive listening socket.
    public static func listen(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        backlog: ISO_9945.Kernel.Socket.Backlog = .max
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try listen(fd: descriptor._rawValue, backlog: backlog)
    }
}

// MARK: - Listen raw fd SPI

extension ISO_9945.Kernel.Socket.Listen {
    /// Marks a raw socket fd as a passive listening socket.
    ///
    /// - Parameters:
    ///   - fd: The socket raw fd (must be SOCK_STREAM or SOCK_SEQPACKET).
    ///   - backlog: Maximum number of pending connections. Defaults to system maximum.
    /// - Throws: `ISO_9945.Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.operationNotSupported)` (EOPNOTSUPP): Socket type does not support listen.
    /// - `.platform(.addressInUse)` (EADDRINUSE): Another socket is listening on this address.
    internal static func listen(
        fd: Int32,
        backlog: ISO_9945.Kernel.Socket.Backlog = .max
    ) throws(ISO_9945.Kernel.Socket.Error) {
        let rc = unsafe Darwin_or_Glibc_listen(fd, backlog.rawValue)

        guard rc == 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }
    }
}

private func Darwin_or_Glibc_listen(_ fd: Int32, _ backlog: Int32) -> Int32 {
    #if canImport(Darwin)
        unsafe Darwin.listen(fd, backlog)
    #elseif canImport(Glibc)
        unsafe Glibc.listen(fd, backlog)
    #elseif canImport(Musl)
        unsafe Musl.listen(fd, backlog)
    #endif
}
