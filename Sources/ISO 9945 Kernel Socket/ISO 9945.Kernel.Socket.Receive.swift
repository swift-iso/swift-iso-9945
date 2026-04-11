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
    /// Socket receive namespace.
    public enum Receive {}
}

// MARK: - Receive Operations

extension ISO_9945.Kernel.Socket.Receive {
    /// Receives data from a connected socket.
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor (must be connected).
    ///   - buffer: Pointer to the buffer to receive into.
    ///   - length: Maximum number of bytes to receive.
    ///   - options: Message flags (default: none).
    /// - Returns: The number of bytes received, or 0 for EOF.
    /// - Throws: `Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.wouldBlock)` (EAGAIN): Non-blocking and no data available.
    /// - `.platform(.connectionReset)` (ECONNRESET): Peer reset the connection.
    /// - `.platform(.notConnected)` (ENOTCONN): Socket is not connected.
    public static func receive(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        buffer: UnsafeMutableRawPointer,
        length: Int,
        options: Kernel.Socket.Message.Options = []
    ) throws(Kernel.Socket.Error) -> Int {
        let result = unsafe Darwin_or_Glibc_recv(
            descriptor._rawValue,
            buffer,
            length,
            options.rawValue
        )

        guard result >= 0 else {
            throw Kernel.Socket.Error.current()
        }

        return result
    }

    /// Receives data and the sender's address (for connectionless sockets).
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor.
    ///   - buffer: Pointer to the buffer to receive into.
    ///   - length: Maximum number of bytes to receive.
    ///   - options: Message flags (default: none).
    /// - Returns: The number of bytes received, the sender's address, and address length.
    /// - Throws: `Kernel.Socket.Error` on failure.
    public static func receiveFrom(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        buffer: UnsafeMutableRawPointer,
        length: Int,
        options: Kernel.Socket.Message.Options = []
    ) throws(Kernel.Socket.Error) -> (count: Int, address: Kernel.Socket.Address.Storage, addressLength: UInt32) {
        var storage = Kernel.Socket.Address.Storage()
        var addrLen = socklen_t(Kernel.Socket.Address.Storage.size)

        let count = storage.withUnsafeMutableBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe recvfrom(
                descriptor._rawValue,
                buffer,
                length,
                options.rawValue,
                sockaddrPtr,
                &addrLen
            )
        }

        guard count >= 0 else {
            throw Kernel.Socket.Error.current()
        }

        return (count: count, address: storage, addressLength: addrLen)
    }

    /// Receives a message with full control over headers and ancillary data.
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor.
    ///   - header: The message header describing receive buffers and control data.
    ///   - options: Message flags (default: none).
    /// - Returns: The number of bytes received.
    /// - Throws: `Kernel.Socket.Error` on failure.
    public static func message(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        header: inout Kernel.Socket.Message.Header,
        options: Kernel.Socket.Message.Options = []
    ) throws(Kernel.Socket.Error) -> Int {
        let result = unsafe recvmsg(
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

private func Darwin_or_Glibc_recv(_ fd: Int32, _ buf: UnsafeMutableRawPointer, _ len: Int, _ flags: Int32) -> Int {
    #if canImport(Darwin)
        unsafe Darwin.recv(fd, buf, len, flags)
    #elseif canImport(Glibc)
        unsafe Glibc.recv(fd, buf, len, flags)
    #elseif canImport(Musl)
        unsafe Musl.recv(fd, buf, len, flags)
    #endif
}
