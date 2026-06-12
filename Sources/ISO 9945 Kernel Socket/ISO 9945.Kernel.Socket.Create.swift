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

public import ISO_9945_Core

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

// MARK: - Create typed (Phase 1.5)
//
// The created socket is typed at birth: `socket(2)` is the ownership
// boundary, so the raw fd is wrapped into the move-only Descriptor here
// rather than handed downstream as `Int32`. Dropping the returned value
// closes the socket via Descriptor deinit instead of leaking the fd.

extension ISO_9945.Kernel.Socket.Create {
    /// Creates a new socket.
    ///
    /// - Parameters:
    ///   - domain: The address family (e.g., `.inet`, `.inet6`, `.unix`).
    ///   - kind: The socket type (e.g., `.stream`, `.datagram`).
    ///   - protocol: The protocol number (0 for default protocol for the given domain/kind).
    /// - Returns: A new socket descriptor. Move-only; the underlying fd
    ///   is closed when the value is dropped without explicit close.
    /// - Throws: `ISO_9945.Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.permissionDenied)` (EACCES): Permission denied for socket type.
    /// - `.platform(.invalidArgument)` (EINVAL): Unknown domain or socket type.
    /// - `.platform(.tooManyFiles)` (EMFILE/ENFILE): File descriptor limit reached.
    public static func create(
        domain: ISO_9945.Kernel.Socket.Address.Family,
        kind: ISO_9945.Kernel.Socket.Kind,
        protocol: Int32 = 0
    ) throws(ISO_9945.Kernel.Socket.Error) -> ISO_9945.Kernel.Socket.Descriptor {
        let fd = socket(domain.rawValue, kind.rawValue, `protocol`)

        guard fd >= 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }

        return ISO_9945.Kernel.Socket.Descriptor(_raw: fd)
    }
}
