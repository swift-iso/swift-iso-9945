#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Address {
    /// IPv6 socket address.
    ///
    /// Wraps `sockaddr_in6`.
    public struct IPv6: @unchecked Sendable {
        internal var cValue: sockaddr_in6

        /// Creates an IPv6 address with only the port set; the address bytes
        /// are zero (the unspecified address, `::`).
        ///
        /// - Parameters:
        ///   - port: Port number in host byte order.
        public init(port: UInt16 = 0) {
            self.cValue = sockaddr_in6()
            self.cValue.sin6_family = sa_family_t(AF_INET6)
            self.cValue.sin6_port = port.bigEndian
        }

        /// Creates an IPv6 address from 16 raw bytes plus port / flow /
        /// scope metadata.
        ///
        /// Per POSIX, `sockaddr_in6.sin6_addr` is a 16-byte quantity — the
        /// address in network byte order. This init accepts those 16 bytes
        /// directly and writes them into `sin6_addr`; no endianness
        /// conversion is applied to the address bytes (they are already the
        /// wire representation).
        ///
        /// - Parameters:
        ///   - address: The 16 bytes of the IPv6 address in network byte
        ///     order (first byte on the wire is `address.0`).
        ///   - port: Port number in host byte order.
        ///   - flowInfo: IPv6 flow information field.
        ///   - scopeId: IPv6 scope identifier.
        public init(
            address: (
                UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
            ),
            port: UInt16 = 0,
            flowInfo: UInt32 = 0,
            scopeId: UInt32 = 0
        ) {
            self.cValue = sockaddr_in6()
            self.cValue.sin6_family = sa_family_t(AF_INET6)
            self.cValue.sin6_port = port.bigEndian
            self.cValue.sin6_flowinfo = flowInfo
            self.cValue.sin6_scope_id = scopeId
            unsafe withUnsafeMutableBytes(of: &self.cValue.sin6_addr) { dst in
                unsafe withUnsafeBytes(of: address) { src in
                    unsafe dst.copyMemory(from: src)
                }
            }
        }
    }
}

// MARK: - Accessors

extension ISO_9945.Kernel.Socket.Address.IPv6 {
    /// The address family (always `.inet6`).
    public var family: ISO_9945.Kernel.Socket.Address.Family {
        .inet6
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
    public static var size: ISO_9945.Kernel.Socket.Address.Length {
        ISO_9945.Kernel.Socket.Address.Length(UInt(MemoryLayout<sockaddr_in6>.size))
    }
}

// MARK: - Convenience

extension ISO_9945.Kernel.Socket.Address.IPv6 {
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

extension ISO_9945.Kernel.Socket.Address.IPv6 {
    /// Converts to the generic `Storage` container.
    public var storage: ISO_9945.Kernel.Socket.Address.Storage {
        var result = ISO_9945.Kernel.Socket.Address.Storage()
        unsafe withUnsafePointer(to: cValue) { src in
            unsafe withUnsafeMutablePointer(to: &result.cValue) { dst in
                unsafe UnsafeMutableRawPointer(dst)
                    .copyMemory(from: src, byteCount: MemoryLayout<sockaddr_in6>.size)
            }
        }
        return result
    }
}
