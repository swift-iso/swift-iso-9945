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
    /// Socket name query namespace.
    public enum Name {}
}

// MARK: - Name raw fd SPI

extension ISO_9945.Kernel.Socket.Name {
    /// Gets the local address of a raw socket fd.
    ///
    /// - Parameter fd: The socket raw fd.
    /// - Returns: The local address and its length.
    /// - Throws: `Kernel.Socket.Error` on failure.
    @_spi(Syscall)
    public static func local(
        fd: Int32
    ) throws(Kernel.Socket.Error) -> (address: Kernel.Socket.Address.Storage, length: Kernel.Socket.Address.Length) {
        var storage = Kernel.Socket.Address.Storage()
        var addrLen = socklen_t(Kernel.Socket.Address.Storage.size.rawValue.rawValue)

        let rc = storage.withUnsafeMutableBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe getsockname(fd, sockaddrPtr, &addrLen)
        }

        guard rc == 0 else {
            throw Kernel.Socket.Error.current()
        }

        return (address: storage, length: Kernel.Socket.Address.Length(addrLen))
    }

    /// Gets the remote address of a connected raw socket fd.
    ///
    /// - Parameter fd: The socket raw fd (must be connected).
    /// - Returns: The peer address and its length.
    /// - Throws: `Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.notConnected)` (ENOTCONN): Socket is not connected.
    @_spi(Syscall)
    public static func peer(
        fd: Int32
    ) throws(Kernel.Socket.Error) -> (address: Kernel.Socket.Address.Storage, length: Kernel.Socket.Address.Length) {
        var storage = Kernel.Socket.Address.Storage()
        var addrLen = socklen_t(Kernel.Socket.Address.Storage.size.rawValue.rawValue)

        let rc = storage.withUnsafeMutableBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe getpeername(fd, sockaddrPtr, &addrLen)
        }

        guard rc == 0 else {
            throw Kernel.Socket.Error.current()
        }

        return (address: storage, length: Kernel.Socket.Address.Length(addrLen))
    }
}
