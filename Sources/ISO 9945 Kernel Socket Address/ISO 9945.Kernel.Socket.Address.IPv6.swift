public import Kernel_Socket_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.Socket.Address {
    /// IPv6 socket address.
    ///
    /// Wraps `sockaddr_in6`.
    public struct IPv6: @unchecked Sendable {
        internal var cValue: sockaddr_in6

        /// Creates an IPv6 address.
        ///
        /// - Parameters:
        ///   - port: Port number in host byte order.
        public init(port: UInt16 = 0) {
            self.cValue = sockaddr_in6()
            self.cValue.sin6_family = sa_family_t(AF_INET6)
            self.cValue.sin6_port = port.bigEndian
        }
    }
}

// MARK: - Accessors

extension Kernel.Socket.Address.IPv6 {
    /// The address family (always `.inet6`).
    public var family: Kernel.Socket.Address.Family {
        get { .inet6 }
    }

    /// Port number in host byte order.
    public var port: UInt16 {
        get { UInt16(bigEndian: cValue.sin6_port) }
        set { cValue.sin6_port = newValue.bigEndian }
    }

    /// Flow information.
    public var flowInfo: UInt32 {
        get { cValue.sin6_flowinfo }
        set { cValue.sin6_flowinfo = newValue }
    }

    /// Scope ID.
    public var scopeId: UInt32 {
        get { cValue.sin6_scope_id }
        set { cValue.sin6_scope_id = newValue }
    }

    /// The size of the underlying sockaddr_in6 structure.
    public static var size: UInt32 {
        UInt32(MemoryLayout<sockaddr_in6>.size)
    }
}

// MARK: - Convenience

extension Kernel.Socket.Address.IPv6 {
    /// Any address (in6addr_any) on the given port.
    public static func any(port: UInt16) -> Self {
        Self(port: port)
    }

    /// Loopback address (::1) on the given port.
    public static func loopback(port: UInt16) -> Self {
        var addr = Self(port: port)
        addr.cValue.sin6_addr = in6addr_loopback
        return addr
    }
}

// MARK: - Storage Conversion

extension Kernel.Socket.Address.IPv6 {
    /// Converts to the generic `Storage` container.
    public var storage: Kernel.Socket.Address.Storage {
        var result = Kernel.Socket.Address.Storage()
        unsafe withUnsafePointer(to: cValue) { src in
            unsafe withUnsafeMutablePointer(to: &result.cValue) { dst in
                unsafe UnsafeMutableRawPointer(dst)
                    .copyMemory(from: src, byteCount: MemoryLayout<sockaddr_in6>.size)
            }
        }
        return result
    }
}
