@_spi(Syscall) import Kernel_Socket_Primitives
@_spi(Syscall) public import ISO_9945_Kernel_Descriptor

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

// MARK: - Bind Operation

extension ISO_9945.Kernel.Socket.Bind {
    /// Binds a socket to a local address.
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor.
    ///   - address: The address to bind to, as a `Storage` container.
    ///   - length: The size of the actual address within storage.
    /// - Throws: `Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.addressInUse)` (EADDRINUSE): Address already bound.
    /// - `.platform(.accessDenied)` (EACCES): Privileged port or restricted address.
    /// - `.platform(.invalidArgument)` (EINVAL): Socket already bound.
    public static func bind(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        address: Kernel.Socket.Address.Storage,
        length: Kernel.Socket.Address.Length
    ) throws(Kernel.Socket.Error) {
        let rc = address.withUnsafeBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe Darwin_or_Glibc_bind(descriptor._rawValue, sockaddrPtr, socklen_t(length.rawValue.rawValue))
        }

        guard rc == 0 else {
            throw Kernel.Socket.Error.current()
        }
    }

    /// Binds a socket to an IPv4 address.
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor.
    ///   - address: The IPv4 address to bind to.
    /// - Throws: `Kernel.Socket.Error` on failure.
    public static func bind(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        address: Kernel.Socket.Address.IPv4
    ) throws(Kernel.Socket.Error) {
        try bind(descriptor, address: address.storage, length: Kernel.Socket.Address.IPv4.size)
    }

    /// Binds a socket to an IPv6 address.
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor.
    ///   - address: The IPv6 address to bind to.
    /// - Throws: `Kernel.Socket.Error` on failure.
    public static func bind(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        address: Kernel.Socket.Address.IPv6
    ) throws(Kernel.Socket.Error) {
        try bind(descriptor, address: address.storage, length: Kernel.Socket.Address.IPv6.size)
    }

    /// Binds a socket to a Unix domain address.
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor.
    ///   - address: The Unix domain address to bind to.
    /// - Throws: `Kernel.Socket.Error` on failure.
    public static func bind(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        address: Kernel.Socket.Address.Unix
    ) throws(Kernel.Socket.Error) {
        try bind(descriptor, address: address.storage, length: Kernel.Socket.Address.Length(UInt(MemoryLayout<sockaddr_un>.size)))
    }
}

// MARK: - Bind raw fd SPI
//
// Spec-literal raw form taking `fd: Int32`. The L3-policy typed-descriptor
// convenience for `borrowing Kernel.Descriptor` lives at swift-posix per
// [PLAT-ARCH-005] / [PLAT-ARCH-008e].

extension ISO_9945.Kernel.Socket.Bind {
    /// Binds a raw socket fd to a local address.
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
}

// MARK: - Typed Convenience (Phase 1.5)

extension ISO_9945.Kernel.Socket.Bind {
    /// Binds a socket to a local address using a typed POSIX descriptor.
    ///
    /// Phase 1.5 typed L2 form. Delegates to the raw `bind(fd:address:length:)`
    /// SPI. For typed callers using socket-specific subtypes, the
    /// `Kernel.Socket.Descriptor` overloads (Storage / IPv4 / IPv6 / Unix) above
    /// remain available.
    public static func bind(
        _ descriptor: borrowing POSIX.Kernel.Descriptor,
        address: Kernel.Socket.Address.Storage,
        length: Kernel.Socket.Address.Length
    ) throws(Kernel.Socket.Error) {
        try bind(fd: descriptor._rawValue, address: address, length: length)
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
