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
    /// Socket connect namespace.
    public enum Connect {}
}

// MARK: - Connect Operation

extension ISO_9945.Kernel.Socket.Connect {
    /// Initiates a connection on a socket.
    ///
    /// For stream sockets (SOCK_STREAM), establishes a connection to the peer.
    /// For datagram sockets (SOCK_DGRAM), sets the default destination address.
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor.
    ///   - address: The peer address, as a `Storage` container.
    ///   - length: The size of the actual address within storage.
    /// - Throws: `Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.connectionRefused)` (ECONNREFUSED): No one listening on the remote address.
    /// - `.platform(.timedOut)` (ETIMEDOUT): Connection attempt timed out.
    /// - `.platform(.networkUnreachable)` (ENETUNREACH): Network is unreachable.
    /// - `.platform(.inProgress)` (EINPROGRESS): Non-blocking connect initiated.
    /// - `.platform(.alreadyConnected)` (EISCONN): Socket is already connected.
    public static func connect(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        address: Kernel.Socket.Address.Storage,
        length: UInt32
    ) throws(Kernel.Socket.Error) {
        let rc = address.withUnsafeBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe Darwin_or_Glibc_connect(descriptor._rawValue, sockaddrPtr, socklen_t(length))
        }

        guard rc == 0 else {
            throw Kernel.Socket.Error.current()
        }
    }

    /// Connects a socket to an IPv4 address.
    public static func connect(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        address: Kernel.Socket.Address.IPv4
    ) throws(Kernel.Socket.Error) {
        try connect(descriptor, address: address.storage, length: Kernel.Socket.Address.IPv4.size)
    }

    /// Connects a socket to an IPv6 address.
    public static func connect(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        address: Kernel.Socket.Address.IPv6
    ) throws(Kernel.Socket.Error) {
        try connect(descriptor, address: address.storage, length: Kernel.Socket.Address.IPv6.size)
    }

    /// Connects a socket to a Unix domain address.
    public static func connect(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        address: Kernel.Socket.Address.Unix
    ) throws(Kernel.Socket.Error) {
        try connect(descriptor, address: address.storage, length: UInt32(MemoryLayout<sockaddr_un>.size))
    }
}

private func Darwin_or_Glibc_connect(_ fd: Int32, _ addr: UnsafePointer<sockaddr>, _ len: socklen_t) -> Int32 {
    #if canImport(Darwin)
        unsafe Darwin.connect(fd, addr, len)
    #elseif canImport(Glibc)
        unsafe Glibc.connect(fd, addr, len)
    #elseif canImport(Musl)
        unsafe Musl.connect(fd, addr, len)
    #endif
}
