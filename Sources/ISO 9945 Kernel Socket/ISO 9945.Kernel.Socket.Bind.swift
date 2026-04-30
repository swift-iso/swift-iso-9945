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
    /// Socket bind namespace.
    public enum Bind {}
}

// MARK: - Bind raw fd SPI
//
// Per Cycle 21, the L2 Kernel Socket API is canonical-raw: takes `fd: Int32`.
// L3-policy typed-descriptor convenience lives at swift-posix per
// [PLAT-ARCH-005] / [PLAT-ARCH-008e]. Typed convenience overloads on
// Kernel.Socket.Descriptor / Kernel.Descriptor were dropped per L1-domain-only
// architecture.

extension ISO_9945.Kernel.Socket.Bind {
    /// Binds a raw socket fd to a local address.
    ///
    /// - Parameters:
    ///   - fd: The socket raw fd.
    ///   - address: The address to bind to, as a `Storage` container.
    ///   - length: The size of the actual address within storage.
    /// - Throws: `Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.addressInUse)` (EADDRINUSE): Address already bound.
    /// - `.platform(.accessDenied)` (EACCES): Privileged port or restricted address.
    /// - `.platform(.invalidArgument)` (EINVAL): Socket already bound.
    @_spi(Syscall)
    public static func bind(
        fd: Int32,
        address: Kernel.Socket.Address.Storage,
        length: Kernel.Socket.Address.Length
    ) throws(Kernel.Socket.Error) {
        let rc = address.withUnsafeBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe Darwin_or_Glibc_bind(fd, sockaddrPtr, socklen_t(length.rawValue.rawValue))
        }

        guard rc == 0 else {
            throw Kernel.Socket.Error.current()
        }
    }

    /// Binds a raw socket fd to an IPv4 address.
    @_spi(Syscall)
    public static func bind(
        fd: Int32,
        address: Kernel.Socket.Address.IPv4
    ) throws(Kernel.Socket.Error) {
        try bind(fd: fd, address: address.storage, length: Kernel.Socket.Address.IPv4.size)
    }

    /// Binds a raw socket fd to an IPv6 address.
    @_spi(Syscall)
    public static func bind(
        fd: Int32,
        address: Kernel.Socket.Address.IPv6
    ) throws(Kernel.Socket.Error) {
        try bind(fd: fd, address: address.storage, length: Kernel.Socket.Address.IPv6.size)
    }

    /// Binds a raw socket fd to a Unix domain address.
    @_spi(Syscall)
    public static func bind(
        fd: Int32,
        address: Kernel.Socket.Address.Unix
    ) throws(Kernel.Socket.Error) {
        try bind(fd: fd, address: address.storage, length: Kernel.Socket.Address.Length(UInt(MemoryLayout<sockaddr_un>.size)))
    }
}

// MARK: - Platform bind disambiguation

/// `bind` is shadowed by Swift's `Sequence.bind`. Use a disambiguating name internally.
private func Darwin_or_Glibc_bind(_ fd: Int32, _ addr: UnsafePointer<sockaddr>, _ len: socklen_t) -> Int32 {
    #if canImport(Darwin)
        unsafe Darwin.bind(fd, addr, len)
    #elseif canImport(Glibc)
        unsafe Glibc.bind(fd, addr, len)
    #elseif canImport(Musl)
        unsafe Musl.bind(fd, addr, len)
    #endif
}
