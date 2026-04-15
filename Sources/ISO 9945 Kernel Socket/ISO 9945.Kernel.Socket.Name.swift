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
    /// Socket name query namespace.
    public enum Name {}
}

// MARK: - Name Operations

extension ISO_9945.Kernel.Socket.Name {
    /// Gets the local address of a socket.
    ///
    /// - Parameter descriptor: The socket descriptor.
    /// - Returns: The local address and its length.
    /// - Throws: `Kernel.Socket.Error` on failure.
    public static func local(
        _ descriptor: borrowing Kernel.Socket.Descriptor
    ) throws(Kernel.Socket.Error) -> (address: Kernel.Socket.Address.Storage, length: UInt32) {
        var storage = Kernel.Socket.Address.Storage()
        var addrLen = socklen_t(Kernel.Socket.Address.Storage.size)

        let rc = storage.withUnsafeMutableBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe getsockname(descriptor._rawValue, sockaddrPtr, &addrLen)
        }

        guard rc == 0 else {
            throw Kernel.Socket.Error.current()
        }

        return (address: storage, length: addrLen)
    }

    /// Gets the remote address of a connected socket.
    ///
    /// - Parameter descriptor: The socket descriptor (must be connected).
    /// - Returns: The peer address and its length.
    /// - Throws: `Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.notConnected)` (ENOTCONN): Socket is not connected.
    public static func peer(
        _ descriptor: borrowing Kernel.Socket.Descriptor
    ) throws(Kernel.Socket.Error) -> (address: Kernel.Socket.Address.Storage, length: UInt32) {
        var storage = Kernel.Socket.Address.Storage()
        var addrLen = socklen_t(Kernel.Socket.Address.Storage.size)

        let rc = storage.withUnsafeMutableBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe getpeername(descriptor._rawValue, sockaddrPtr, &addrLen)
        }

        guard rc == 0 else {
            throw Kernel.Socket.Error.current()
        }

        return (address: storage, length: addrLen)
    }
}

// MARK: - Name queries on Kernel.Descriptor

extension ISO_9945.Kernel.Socket.Name {
    /// Gets the local address of a socket.
    ///
    /// Overload on `borrowing Kernel.Descriptor` for consumers storing the
    /// socket as a generic descriptor.
    public static func local(
        _ descriptor: borrowing Kernel.Descriptor
    ) throws(Kernel.Socket.Error) -> (address: Kernel.Socket.Address.Storage, length: UInt32) {
        var storage = Kernel.Socket.Address.Storage()
        var addrLen = socklen_t(Kernel.Socket.Address.Storage.size)

        let rc = storage.withUnsafeMutableBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe getsockname(descriptor._rawValue, sockaddrPtr, &addrLen)
        }

        guard rc == 0 else {
            throw Kernel.Socket.Error.current()
        }

        return (address: storage, length: addrLen)
    }

    /// Gets the remote address of a connected socket.
    ///
    /// Overload on `borrowing Kernel.Descriptor` for consumers storing the
    /// socket as a generic descriptor.
    public static func peer(
        _ descriptor: borrowing Kernel.Descriptor
    ) throws(Kernel.Socket.Error) -> (address: Kernel.Socket.Address.Storage, length: UInt32) {
        var storage = Kernel.Socket.Address.Storage()
        var addrLen = socklen_t(Kernel.Socket.Address.Storage.size)

        let rc = storage.withUnsafeMutableBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe getpeername(descriptor._rawValue, sockaddrPtr, &addrLen)
        }

        guard rc == 0 else {
            throw Kernel.Socket.Error.current()
        }

        return (address: storage, length: addrLen)
    }
}
