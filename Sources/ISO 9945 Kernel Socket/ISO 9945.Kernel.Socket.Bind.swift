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
#elseif canImport(Android)
    internal import Android
#else
    #error("ISO_9945.Kernel.Socket.Bind: unsupported platform (no Darwin, Glibc, Musl, or Android)")
#endif

extension ISO_9945.Kernel.Socket {
    /// Socket bind namespace.
    public enum Bind {}
}

// MARK: - Bind raw fd SPI
//
// Typed Phase-1.5 forms re-added in Wave 4c-Socket Main (2026-05-01) per
// [PLAT-ARCH-005] three-tier chain (Prerequisite II). The typed L2 forms
// take `borrowing ISO_9945.Kernel.Socket.Descriptor` (= typealias to
// `ISO_9945.Kernel.Descriptor`); L3-policy callers (swift-posix) hold
// `borrowing POSIX.Kernel.Socket.Descriptor` (= same compile-time type
// via the Prerequisite II typealias chain) and pass through directly,
// eliminating the round-trip `descriptor._rawValue` → `init(_rawValue:)`.
// The `@_spi(Syscall) (fd: Int32, ...)` raw companions are retained for
// SPI bridge consumers; they will be downgraded in a Wave 4c retire-cycle.

// MARK: - Bind typed (Phase 1.5)

extension ISO_9945.Kernel.Socket.Bind {
    /// Binds a typed socket descriptor to a local address.
    public static func bind(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        address: ISO_9945.Kernel.Socket.Address.Storage,
        length: ISO_9945.Kernel.Socket.Address.Length
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try bind(fd: descriptor._rawValue, address: address, length: length)
    }

    /// Binds a typed socket descriptor to an IPv4 address.
    public static func bind(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        address: ISO_9945.Kernel.Socket.Address.IPv4
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try bind(fd: descriptor._rawValue, address: address)
    }

    /// Binds a typed socket descriptor to an IPv6 address.
    public static func bind(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        address: ISO_9945.Kernel.Socket.Address.IPv6
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try bind(fd: descriptor._rawValue, address: address)
    }

    /// Binds a typed socket descriptor to a Unix domain address.
    public static func bind(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        address: ISO_9945.Kernel.Socket.Address.Unix
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try bind(fd: descriptor._rawValue, address: address)
    }
}

extension ISO_9945.Kernel.Socket.Bind {
    /// Binds a raw socket fd to a local address.
    ///
    /// - Parameters:
    ///   - fd: The socket raw fd.
    ///   - address: The address to bind to, as a `Storage` container.
    ///   - length: The size of the actual address within storage.
    /// - Throws: `ISO_9945.Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.addressInUse)` (EADDRINUSE): Address already bound.
    /// - `.platform(.accessDenied)` (EACCES): Privileged port or restricted address.
    /// - `.platform(.invalidArgument)` (EINVAL): Socket already bound.
    internal static func bind(
        fd: Int32,
        address: ISO_9945.Kernel.Socket.Address.Storage,
        length: ISO_9945.Kernel.Socket.Address.Length
    ) throws(ISO_9945.Kernel.Socket.Error) {
        let rc = unsafe address.withUnsafeBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe platformBind(
                fd,
                sockaddrPtr,
                socklen_t(length.underlying.rawValue)
            )
        }

        guard rc == 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }
    }

    /// Binds a raw socket fd to an IPv4 address.
    internal static func bind(
        fd: Int32,
        address: ISO_9945.Kernel.Socket.Address.IPv4
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try bind(fd: fd, address: address.storage, length: ISO_9945.Kernel.Socket.Address.IPv4.size)
    }

    /// Binds a raw socket fd to an IPv6 address.
    internal static func bind(
        fd: Int32,
        address: ISO_9945.Kernel.Socket.Address.IPv6
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try bind(fd: fd, address: address.storage, length: ISO_9945.Kernel.Socket.Address.IPv6.size)
    }

    /// Binds a raw socket fd to a Unix domain address.
    internal static func bind(
        fd: Int32,
        address: ISO_9945.Kernel.Socket.Address.Unix
    ) throws(ISO_9945.Kernel.Socket.Error) {
        // Pass the used portion of sun_path, not the full struct size:
        // a full-struct length runs past the terminator, which Linux
        // reads as an abstract-namespace name and Darwin rejects.
        try bind(fd: fd, address: address.storage, length: address.length)
    }
}

// MARK: - Platform bind disambiguation

/// `bind` is shadowed by Swift's `Sequence.bind`. Use a disambiguating name internally.
private func platformBind(
    _ fd: Int32,
    _ addr: UnsafePointer<sockaddr>,
    _ len: socklen_t
) -> Int32 {
    #if canImport(Darwin)
        unsafe Darwin.bind(fd, addr, len)
    #elseif canImport(Glibc)
        unsafe Glibc.bind(fd, addr, len)
    #elseif canImport(Musl)
        unsafe Musl.bind(fd, addr, len)
    #elseif canImport(Android)
        unsafe Android.bind(fd, addr, len)
    #else
        #error(
            "ISO_9945.Kernel.Socket.Bind: unsupported platform (no Darwin, Glibc, Musl, or Android)"
        )
    #endif
}
