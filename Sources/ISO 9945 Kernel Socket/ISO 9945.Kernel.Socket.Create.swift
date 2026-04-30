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

extension ISO_9945.Kernel.Socket {
    /// Socket creation namespace.
    public enum Create {}
}

// MARK: - Create Operation (raw fd SPI)
//
// Per Cycle 21 (transitional), L2 syscall API returns raw `Int32`. L3-policy
// callers at swift-posix wrap into POSIX.Kernel.Socket.Descriptor.

extension ISO_9945.Kernel.Socket.Create {
    /// Creates a new socket.
    ///
    /// - Parameters:
    ///   - domain: The address family (e.g., `.inet`, `.inet6`, `.unix`).
    ///   - kind: The socket type (e.g., `.stream`, `.datagram`).
    ///   - protocol: The protocol number (0 for default protocol for the given domain/kind).
    /// - Returns: A new socket file descriptor (raw POSIX fd).
    /// - Throws: `Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.permissionDenied)` (EACCES): Permission denied for socket type.
    /// - `.platform(.invalidArgument)` (EINVAL): Unknown domain or socket type.
    /// - `.platform(.tooManyFiles)` (EMFILE/ENFILE): File descriptor limit reached.
    @_spi(Syscall)
    public static func create(
        domain: Kernel.Socket.Address.Family,
        kind: Kernel.Socket.Kind,
        protocol: Int32 = 0
    ) throws(Kernel.Socket.Error) -> Int32 {
        let fd = socket(domain.rawValue, kind.rawValue, `protocol`)

        guard fd >= 0 else {
            throw Kernel.Socket.Error.current()
        }

        return fd
    }
}
