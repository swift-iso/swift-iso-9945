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
    /// Socket receive namespace.
    public enum Receive {}
}

// MARK: - Receive typed (Phase 1.5)
//
// Typed Phase-1.5 forms re-added in Wave 4c-Socket Main (2026-05-01) per
// [PLAT-ARCH-005] three-tier chain (Prerequisite II).

extension ISO_9945.Kernel.Socket.Receive {
    /// Receives data from a connected typed socket descriptor into a mutable span.
    public static func receive(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        into span: inout MutableSpan<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try receive(fd: descriptor._rawValue, into: &span, options: options)
    }

    /// Receives data and the sender's address into a mutable span.
    public static func from(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        into span: inout MutableSpan<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> (count: Int, address: ISO_9945.Kernel.Socket.Address.Storage, addressLength: ISO_9945.Kernel.Socket.Address.Length) {
        try from(fd: descriptor._rawValue, into: &span, options: options)
    }

    /// Receives a message with full control over headers and ancillary data.
    public static func message(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        header: inout ISO_9945.Kernel.Socket.Message.Header,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try message(fd: descriptor._rawValue, header: &header, options: options)
    }
}

// MARK: - Receive Operations (raw fd SPI)

extension ISO_9945.Kernel.Socket.Receive {
    /// Receives data from a connected socket into a mutable span.
    ///
    /// - Parameters:
    ///   - fd: The socket raw fd (must be connected).
    ///   - span: The mutable span to receive into.
    ///   - options: Message flags (default: none).
    /// - Returns: The number of bytes received, or 0 for EOF.
    /// - Throws: `ISO_9945.Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.wouldBlock)` (EAGAIN): Non-blocking and no data available.
    /// - `.platform(.connectionReset)` (ECONNRESET): Peer reset the connection.
    /// - `.platform(.notConnected)` (ENOTCONN): Socket is not connected.
    internal static func receive(
        fd: Int32,
        into span: inout MutableSpan<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try unsafe span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(ISO_9945.Kernel.Socket.Error) -> Int in
            guard let base = buffer.baseAddress else { return 0 }
            let result = unsafe Darwin_or_Glibc_recv(
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

    /// Receives data and the sender's address into a mutable span.
    ///
    /// - Parameters:
    ///   - fd: The socket raw fd.
    ///   - span: The mutable span to receive into.
    ///   - options: Message flags (default: none).
    /// - Returns: The number of bytes received, the sender's address, and address length.
    /// - Throws: `ISO_9945.Kernel.Socket.Error` on failure.
    internal static func from(
        fd: Int32,
        into span: inout MutableSpan<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> (count: Int, address: ISO_9945.Kernel.Socket.Address.Storage, addressLength: ISO_9945.Kernel.Socket.Address.Length) {
        try unsafe span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(ISO_9945.Kernel.Socket.Error) -> (count: Int, address: ISO_9945.Kernel.Socket.Address.Storage, addressLength: ISO_9945.Kernel.Socket.Address.Length) in
            guard let base = buffer.baseAddress else {
                return (count: 0, address: ISO_9945.Kernel.Socket.Address.Storage(), addressLength: ISO_9945.Kernel.Socket.Address.Length(UInt(0)))
            }
            var storage = ISO_9945.Kernel.Socket.Address.Storage()
            var addrLen = socklen_t(ISO_9945.Kernel.Socket.Address.Storage.size.underlying.rawValue)

            let count = storage.withUnsafeMutableBytes { ptr, _ in
                let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
                return unsafe recvfrom(
                    fd,
                    base,
                    buffer.count,
                    options.rawValue,
                    sockaddrPtr,
                    &addrLen
                )
            }

            guard count >= 0 else {
                throw ISO_9945.Kernel.Socket.Error.current()
            }

            return (count: count, address: storage, addressLength: ISO_9945.Kernel.Socket.Address.Length(addrLen))
        }
    }

    /// Receives a message with full control over headers and ancillary data.
    ///
    /// - Parameters:
    ///   - fd: The socket raw fd.
    ///   - header: The message header describing receive buffers and control data.
    ///   - options: Message flags (default: none).
    /// - Returns: The number of bytes received.
    /// - Throws: `ISO_9945.Kernel.Socket.Error` on failure.
    internal static func message(
        fd: Int32,
        header: inout ISO_9945.Kernel.Socket.Message.Header,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        let result = unsafe recvmsg(
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

private func Darwin_or_Glibc_recv(_ fd: Int32, _ buf: UnsafeMutableRawPointer, _ len: Int, _ flags: Int32) -> Int {
    #if canImport(Darwin)
        unsafe Darwin.recv(fd, buf, len, flags)
    #elseif canImport(Glibc)
        unsafe Glibc.recv(fd, buf, len, flags)
    #elseif canImport(Musl)
        unsafe Musl.recv(fd, buf, len, flags)
    #endif
}
