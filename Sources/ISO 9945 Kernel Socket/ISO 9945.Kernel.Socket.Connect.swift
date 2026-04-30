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
    /// Socket connect namespace.
    public enum Connect {}
}

// MARK: - Connect Operation (raw fd SPI)
//
// Per Cycle 21 (transitional), L2 syscall API takes raw `fd: Int32`. Typed
// ISO_9945.Kernel.Socket.Descriptor convenience overloads were dropped; the L3
// unifier typealias chain at swift-kernel exposes the typed cross-platform
// name. Post-Path-X cleanup will retype L2 to ISO_9945.Kernel.Socket.Descriptor.

extension ISO_9945.Kernel.Socket.Connect {
    /// Initiates a connection on a socket.
    ///
    /// For stream sockets (SOCK_STREAM), establishes a connection to the peer.
    /// For datagram sockets (SOCK_DGRAM), sets the default destination address.
    ///
    /// - Parameters:
    ///   - fd: The socket raw fd.
    ///   - address: The peer address, as a `Storage` container.
    ///   - length: The size of the actual address within storage.
    /// - Throws: `ISO_9945.Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.connectionRefused)` (ECONNREFUSED): No one listening on the remote address.
    /// - `.platform(.timedOut)` (ETIMEDOUT): Connection attempt timed out.
    /// - `.platform(.networkUnreachable)` (ENETUNREACH): Network is unreachable.
    /// - `.platform(.inProgress)` (EINPROGRESS): Non-blocking connect initiated.
    /// - `.platform(.alreadyConnected)` (EISCONN): Socket is already connected.
    @_spi(Syscall)
    public static func connect(
        fd: Int32,
        address: ISO_9945.Kernel.Socket.Address.Storage,
        length: ISO_9945.Kernel.Socket.Address.Length
    ) throws(ISO_9945.Kernel.Socket.Error) {
        let rc = address.withUnsafeBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe Darwin_or_Glibc_connect(fd, sockaddrPtr, socklen_t(length.rawValue.rawValue))
        }

        guard rc == 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }
    }

    /// Connects a raw socket fd to an IPv4 address.
    @_spi(Syscall)
    public static func connect(
        fd: Int32,
        address: ISO_9945.Kernel.Socket.Address.IPv4
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try connect(fd: fd, address: address.storage, length: ISO_9945.Kernel.Socket.Address.IPv4.size)
    }

    /// Connects a raw socket fd to an IPv6 address.
    @_spi(Syscall)
    public static func connect(
        fd: Int32,
        address: ISO_9945.Kernel.Socket.Address.IPv6
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try connect(fd: fd, address: address.storage, length: ISO_9945.Kernel.Socket.Address.IPv6.size)
    }

    /// Connects a raw socket fd to a Unix domain address.
    @_spi(Syscall)
    public static func connect(
        fd: Int32,
        address: ISO_9945.Kernel.Socket.Address.Unix
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try connect(fd: fd, address: address.storage, length: ISO_9945.Kernel.Socket.Address.Length(UInt(MemoryLayout<sockaddr_un>.size)))
    }
}

// MARK: - Platform disambiguation

private func Darwin_or_Glibc_connect(_ fd: Int32, _ addr: UnsafePointer<sockaddr>, _ len: socklen_t) -> Int32 {
    #if canImport(Darwin)
        unsafe Darwin.connect(fd, addr, len)
    #elseif canImport(Glibc)
        unsafe Glibc.connect(fd, addr, len)
    #elseif canImport(Musl)
        unsafe Musl.connect(fd, addr, len)
    #endif
}
