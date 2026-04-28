@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_Socket_Primitives

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

// MARK: - Send Operations

extension ISO_9945.Kernel.Socket.Send {
    /// Sends data from a span on a connected socket.
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor (must be connected).
    ///   - span: The data to send.
    ///   - options: Message flags (default: none).
    /// - Returns: The number of bytes actually sent.
    /// - Throws: `Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.wouldBlock)` (EAGAIN): Non-blocking and send buffer is full.
    /// - `.platform(.connectionReset)` (ECONNRESET): Peer reset the connection.
    /// - `.platform(.brokenPipe)` (EPIPE): Peer closed the connection.
    /// - `.platform(.notConnected)` (ENOTCONN): Socket is not connected.
    @_disfavoredOverload
    public static func send(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        from span: Span<UInt8>,
        options: Kernel.Socket.Message.Options = []
    ) throws(Kernel.Socket.Error) -> Int {
        try unsafe span.withUnsafeBytes { buffer throws(Kernel.Socket.Error) -> Int in
            guard let base = buffer.baseAddress else { return 0 }
            let result = unsafe Darwin_or_Glibc_send(
                descriptor._rawValue,
                base,
                buffer.count,
                options.rawValue
            )
            guard result >= 0 else {
                throw Kernel.Socket.Error.current()
            }
            return result
        }
    }

    /// Sends data from a span to a specific address (for connectionless sockets).
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor.
    ///   - span: The data to send.
    ///   - options: Message flags (default: none).
    ///   - address: The destination address.
    ///   - addressLength: The size of the destination address.
    /// - Returns: The number of bytes actually sent.
    /// - Throws: `Kernel.Socket.Error` on failure.
    @_disfavoredOverload
    public static func to(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        from span: Span<UInt8>,
        options: Kernel.Socket.Message.Options = [],
        address: Kernel.Socket.Address.Storage,
        addressLength: Kernel.Socket.Address.Length
    ) throws(Kernel.Socket.Error) -> Int {
        try unsafe span.withUnsafeBytes { buffer throws(Kernel.Socket.Error) -> Int in
            guard let base = buffer.baseAddress else { return 0 }
            let result = address.withUnsafeBytes { ptr, _ in
                let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
                return unsafe sendto(
                    descriptor._rawValue,
                    base,
                    buffer.count,
                    options.rawValue,
                    sockaddrPtr,
                    socklen_t(addressLength.rawValue.rawValue)
                )
            }
            guard result >= 0 else {
                throw Kernel.Socket.Error.current()
            }
            return result
        }
    }

    /// Sends a message with full control over headers and ancillary data.
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor.
    ///   - header: The message header describing buffers, address, and control data.
    ///   - options: Message flags (default: none).
    /// - Returns: The number of bytes actually sent.
    /// - Throws: `Kernel.Socket.Error` on failure.
    @_disfavoredOverload
    public static func message(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        header: inout Kernel.Socket.Message.Header,
        options: Kernel.Socket.Message.Options = []
    ) throws(Kernel.Socket.Error) -> Int {
        let result = unsafe sendmsg(
            descriptor._rawValue,
            &header.cValue,
            options.rawValue
        )

        guard result >= 0 else {
            throw Kernel.Socket.Error.current()
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
