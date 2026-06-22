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
    /// Socket send namespace.
    public enum Send {}
}

// MARK: - Send typed (Phase 1.5)
//
// Typed Phase-1.5 forms re-added in Wave 4c-Socket Main (2026-05-01) per
// [PLAT-ARCH-005] three-tier chain (Prerequisite II).

extension ISO_9945.Kernel.Socket.Send {
    /// Sends data from a span on a connected typed socket descriptor.
    public static func send(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        from span: Swift.Span<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try send(fd: descriptor._rawValue, from: span, options: options)
    }

    /// Sends data from a span to a specific address (for connectionless sockets).
    public static func to(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        from span: Swift.Span<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = [],
        address: ISO_9945.Kernel.Socket.Address.Storage,
        addressLength: ISO_9945.Kernel.Socket.Address.Length
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try to(
            fd: descriptor._rawValue,
            from: span,
            options: options,
            address: address,
            addressLength: addressLength
        )
    }

    /// Sends a message with full control over headers and ancillary data.
    public static func message(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        header: inout ISO_9945.Kernel.Socket.Message.Header,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try message(fd: descriptor._rawValue, header: &header, options: options)
    }
}

// MARK: - Send Operations (raw fd SPI)

extension ISO_9945.Kernel.Socket.Send {
    /// Sends data from a span on a connected socket.
    ///
    /// - Parameters:
    ///   - fd: The socket raw fd (must be connected).
    ///   - span: The data to send.
    ///   - options: Message flags (default: none).
    /// - Returns: The number of bytes actually sent.
    /// - Throws: `ISO_9945.Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.wouldBlock)` (EAGAIN): Non-blocking and send buffer is full.
    /// - `.platform(.connectionReset)` (ECONNRESET): Peer reset the connection.
    /// - `.platform(.brokenPipe)` (EPIPE): Peer closed the connection.
    /// - `.platform(.notConnected)` (ENOTCONN): Socket is not connected.
    internal static func send(
        fd: Int32,
        from span: Swift.Span<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try unsafe span.withUnsafeBytes { buffer throws(ISO_9945.Kernel.Socket.Error) -> Int in
            guard let base = buffer.baseAddress else { return 0 }
            let result = unsafe Darwin_or_Glibc_send(
                fd,
                base,
                buffer.count,
                options.rawValue
            )
            guard result >= 0 else {
                throw ISO_9945.Kernel.Socket.Error.current()
            }
            return result
        }
    }

    /// Sends data from a span to a specific address (for connectionless sockets).
    ///
    /// - Parameters:
    ///   - fd: The socket raw fd.
    ///   - span: The data to send.
    ///   - options: Message flags (default: none).
    ///   - address: The destination address.
    ///   - addressLength: The size of the destination address.
    /// - Returns: The number of bytes actually sent.
    /// - Throws: `ISO_9945.Kernel.Socket.Error` on failure.
    internal static func to(
        fd: Int32,
        from span: Swift.Span<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = [],
        address: ISO_9945.Kernel.Socket.Address.Storage,
        addressLength: ISO_9945.Kernel.Socket.Address.Length
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try unsafe span.withUnsafeBytes { buffer throws(ISO_9945.Kernel.Socket.Error) -> Int in
            guard let base = buffer.baseAddress else { return 0 }
            let result = address.withUnsafeBytes { ptr, _ in
                let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
                return unsafe sendto(
                    fd,
                    base,
                    buffer.count,
                    options.rawValue,
                    sockaddrPtr,
                    socklen_t(addressLength.underlying.rawValue)
                )
            }
            guard result >= 0 else {
                throw ISO_9945.Kernel.Socket.Error.current()
            }
            return result
        }
    }

    /// Sends a message with full control over headers and ancillary data.
    ///
    /// - Parameters:
    ///   - fd: The socket raw fd.
    ///   - header: The message header describing buffers, address, and control data.
    ///   - options: Message flags (default: none).
    /// - Returns: The number of bytes actually sent.
    /// - Throws: `ISO_9945.Kernel.Socket.Error` on failure.
    internal static func message(
        fd: Int32,
        header: inout ISO_9945.Kernel.Socket.Message.Header,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        let result = unsafe sendmsg(
            fd,
            &header.cValue,
            options.rawValue
        )

        guard result >= 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }

        return result
    }
}

// MARK: - Platform disambiguation

private func Darwin_or_Glibc_send(_ fd: Int32, _ buf: UnsafeRawPointer, _ len: Int, _ flags: Int32) -> Int {
    #if canImport(Darwin)
        unsafe Darwin.send(fd, buf, len, flags)
    #elseif canImport(Glibc)
        unsafe Glibc.send(fd, buf, len, flags)
    #elseif canImport(Musl)
        unsafe Musl.send(fd, buf, len, flags)
    #endif
}
