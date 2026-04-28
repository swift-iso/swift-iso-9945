public import Kernel_Socket_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.Socket.Address {
    /// IPv4 socket address.
    ///
    /// Wraps `sockaddr_in`. Port and address are stored in network byte order
    /// internally; accessors present host byte order.
    public struct IPv4: @unchecked Sendable, Equatable {
        internal var cValue: sockaddr_in

        /// Creates an IPv4 address.
        ///
        /// - Parameters:
        ///   - address: IPv4 address in network byte order.
        ///   - port: Port number in host byte order.
        public init(address: UInt32 = 0, port: UInt16 = 0) {
            self.cValue = sockaddr_in()
            self.cValue.sin_family = sa_family_t(AF_INET)
            self.cValue.sin_port = port.bigEndian
            self.cValue.sin_addr.s_addr = address
        }
    }
}

// MARK: - Accessors

extension Kernel.Socket.Address.IPv4 {
    /// The address family (always `.inet`).
    public var family: Kernel.Socket.Address.Family {
        get { .inet }
    }

    /// Port number in host byte order.
    public var port: UInt16 {
        get { UInt16(bigEndian: cValue.sin_port) }
        set { cValue.sin_port = newValue.bigEndian }
    }

    /// IPv4 address in network byte order.
    public var address: UInt32 {
        get { cValue.sin_addr.s_addr }
        set { cValue.sin_addr.s_addr = newValue }
    }

    /// The size of the underlying sockaddr_in structure.
    public static var size: Kernel.Socket.Address.Length {
        Kernel.Socket.Address.Length(UInt(MemoryLayout<sockaddr_in>.size))
    }
}

// MARK: - Convenience

extension Kernel.Socket.Address.IPv4 {
    /// Any address (INADDR_ANY) on the given port.
    public static func any(port: UInt16) -> Self {
        Self(address: UInt32(INADDR_ANY).bigEndian, port: port)
    }

    /// Loopback address (127.0.0.1) on the given port.
    public static func loopback(port: UInt16) -> Self {
        Self(address: UInt32(INADDR_LOOPBACK).bigEndian, port: port)
    }
}

// MARK: - Storage Conversion

extension Kernel.Socket.Address.IPv4 {
    /// Converts to the generic `Storage` container.
    public var storage: Kernel.Socket.Address.Storage {
        var result = Kernel.Socket.Address.Storage()
        unsafe withUnsafePointer(to: cValue) { src in
            unsafe withUnsafeMutablePointer(to: &result.cValue) { dst in
                unsafe UnsafeMutableRawPointer(dst)
                    .copyMemory(from: src, byteCount: MemoryLayout<sockaddr_in>.size)
            }
        }
        return result
    }
}

// MARK: - Equatable

extension Kernel.Socket.Address.IPv4 {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.cValue.sin_port == rhs.cValue.sin_port &&
        lhs.cValue.sin_addr.s_addr == rhs.cValue.sin_addr.s_addr
    }
}
