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
    /// Socket accept namespace.
    public enum Accept {}
}

// MARK: - Accept Operation

extension ISO_9945.Kernel.Socket.Accept {
    /// Accepts an incoming connection on a listening socket.
    ///
    /// Blocks until a connection is available (unless the socket is non-blocking).
    ///
    /// - Parameter descriptor: The listening socket descriptor.
    /// - Returns: A result containing the new connected descriptor and peer address.
    /// - Throws: `Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.wouldBlock)` (EAGAIN/EWOULDBLOCK): Non-blocking and no pending connections.
    /// - `.platform(.interrupted)` (EINTR): Signal interrupted the accept.
    /// - `.platform(.connectionAborted)` (ECONNABORTED): Connection aborted before accept.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let result = try Socket.Accept.accept(listenFd)
    /// defer { try? Kernel.Close.close(result.descriptor) }
    /// // result.address contains the peer's address
    /// ```
    @_disfavoredOverload
    public static func accept(
        _ descriptor: borrowing Kernel.Socket.Descriptor
    ) throws(Kernel.Socket.Error) -> Result {
        var storage = Kernel.Socket.Address.Storage()
        var addrLen = socklen_t(Kernel.Socket.Address.Storage.size)

        let fd = storage.withUnsafeMutableBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe Darwin_or_Glibc_accept(descriptor._rawValue, sockaddrPtr, &addrLen)
        }

        guard fd >= 0 else {
            throw Kernel.Socket.Error.current()
        }

        return Result(
            descriptor: Kernel.Socket.Descriptor(_rawValue: fd),
            address: storage,
            length: addrLen
        )
    }
}

private func Darwin_or_Glibc_accept(_ fd: Int32, _ addr: UnsafeMutablePointer<sockaddr>, _ len: UnsafeMutablePointer<socklen_t>) -> Int32 {
    #if canImport(Darwin)
        unsafe Darwin.accept(fd, addr, len)
    #elseif canImport(Glibc)
        unsafe Glibc.accept(fd, addr, len)
    #elseif canImport(Musl)
        unsafe Musl.accept(fd, addr, len)
    #endif
}

// MARK: - Accept on Kernel.Descriptor

extension ISO_9945.Kernel.Socket.Accept {
    /// Accepts an incoming connection on a listening socket.
    ///
    /// Overload on `borrowing Kernel.Descriptor` for consumers storing a
    /// listening socket as a generic descriptor. The returned
    /// `Kernel.Socket.Accept.Result` still carries a typed
    /// `Kernel.Socket.Descriptor` for the new connection — socket typing
    /// resurfaces at the result boundary where socket semantics (address
    /// family, peer tracking) matter.
    @_disfavoredOverload
    public static func accept(
        _ descriptor: borrowing Kernel.Descriptor
    ) throws(Kernel.Socket.Error) -> Result {
        var storage = Kernel.Socket.Address.Storage()
        var addrLen = socklen_t(Kernel.Socket.Address.Storage.size)

        let fd = storage.withUnsafeMutableBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe Darwin_or_Glibc_accept(descriptor._rawValue, sockaddrPtr, &addrLen)
        }

        guard fd >= 0 else {
            throw Kernel.Socket.Error.current()
        }

        return Result(
            descriptor: Kernel.Socket.Descriptor(_rawValue: fd),
            address: storage,
            length: addrLen
        )
    }
}
