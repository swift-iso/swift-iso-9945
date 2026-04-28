@_spi(Syscall) import Kernel_Socket_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket {
    /// Socket listen namespace.
    public enum Listen {}
}

// MARK: - Listen Operation

extension ISO_9945.Kernel.Socket.Listen {
    /// Marks a socket as a passive socket for accepting connections.
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor (must be SOCK_STREAM or SOCK_SEQPACKET).
    ///   - backlog: Maximum number of pending connections. Defaults to system maximum.
    /// - Throws: `Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.operationNotSupported)` (EOPNOTSUPP): Socket type does not support listen.
    /// - `.platform(.addressInUse)` (EADDRINUSE): Another socket is listening on this address.
    public static func listen(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        backlog: Kernel.Socket.Backlog = .max
    ) throws(Kernel.Socket.Error) {
        let rc = unsafe Darwin_or_Glibc_listen(descriptor._rawValue, backlog.rawValue)

        guard rc == 0 else {
            throw Kernel.Socket.Error.current()
        }
    }
}

private func Darwin_or_Glibc_listen(_ fd: Int32, _ backlog: Int32) -> Int32 {
    #if canImport(Darwin)
        unsafe Darwin.listen(fd, backlog)
    #elseif canImport(Glibc)
        unsafe Glibc.listen(fd, backlog)
    #elseif canImport(Musl)
        unsafe Musl.listen(fd, backlog)
    #endif
}

// MARK: - Listen raw fd SPI

extension ISO_9945.Kernel.Socket.Listen {
    /// Marks a raw socket fd as a passive listening socket.
    ///
    /// Spec-literal: takes a raw `Int32` fd. The L3-policy typed-descriptor
    /// convenience lives at swift-posix per [PLAT-ARCH-005] / [PLAT-ARCH-008e].
    @_spi(Syscall)
    public static func listen(
        fd: Int32,
        backlog: Kernel.Socket.Backlog = .max
    ) throws(Kernel.Socket.Error) {
        let rc = unsafe Darwin_or_Glibc_listen(fd, backlog.rawValue)

        guard rc == 0 else {
            throw Kernel.Socket.Error.current()
        }
    }
}
