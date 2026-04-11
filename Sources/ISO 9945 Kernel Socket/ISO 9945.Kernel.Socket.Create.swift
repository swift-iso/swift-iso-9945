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
    /// Socket creation namespace.
    public enum Create {}
}

// MARK: - Create Operation

extension ISO_9945.Kernel.Socket.Create {
    /// Creates a new socket.
    ///
    /// - Parameters:
    ///   - domain: The address family (e.g., `.inet`, `.inet6`, `.unix`).
    ///   - kind: The socket type (e.g., `.stream`, `.datagram`).
    ///   - protocol: The protocol number (0 for default protocol for the given domain/kind).
    /// - Returns: A new socket descriptor. The caller owns this descriptor.
    /// - Throws: `Kernel.Socket.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.platform(.permissionDenied)` (EACCES): Permission denied for socket type.
    /// - `.platform(.invalidArgument)` (EINVAL): Unknown domain or socket type.
    /// - `.platform(.tooManyFiles)` (EMFILE/ENFILE): File descriptor limit reached.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let fd = try Socket.Create.create(domain: .inet, kind: .stream)
    /// defer { try? Kernel.Close.close(fd) }
    /// ```
    public static func create(
        domain: Kernel.Socket.Address.Family,
        kind: Kernel.Socket.Kind,
        protocol: Int32 = 0
    ) throws(Kernel.Socket.Error) -> Kernel.Socket.Descriptor {
        let fd = socket(domain.rawValue, kind.rawValue, `protocol`)

        guard fd >= 0 else {
            throw Kernel.Socket.Error.current()
        }

        return Kernel.Socket.Descriptor(_rawValue: fd)
    }
}
