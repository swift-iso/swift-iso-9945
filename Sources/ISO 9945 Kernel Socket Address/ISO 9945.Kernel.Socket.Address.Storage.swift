public import Kernel_Socket_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.Socket.Address {
    /// Generic socket address container.
    ///
    /// Wraps `sockaddr_storage` — large enough to hold any address family.
    /// Used as the pointer type in accept/connect/bind operations. Callers
    /// create typed addresses (IPv4, IPv6, Unix) and convert via `.storage`.
    public struct Storage: @unchecked Sendable {
        internal var cValue: sockaddr_storage

        /// Creates a zeroed address storage.
        public init() {
            self.cValue = sockaddr_storage()
        }
    }
}

// MARK: - Accessors

extension Kernel.Socket.Address.Storage {
    /// The address family.
    public var family: Kernel.Socket.Address.Family {
        get { Kernel.Socket.Address.Family(rawValue: Int32(cValue.ss_family)) }
    }

    /// The size of the underlying `sockaddr_storage` structure.
    public static var size: UInt32 {
        UInt32(MemoryLayout<sockaddr_storage>.size)
    }
}

// MARK: - Unsafe Access

extension Kernel.Socket.Address.Storage {
    /// Calls `body` with a raw pointer to the underlying address and its size in bytes.
    ///
    /// Used by syscall wrappers (bind, connect) that need a `sockaddr *` parameter.
    /// The pointer is valid only for the duration of the closure.
    public func withUnsafeBytes<R, E: Swift.Error>(
        _ body: (UnsafeRawPointer, UInt32) throws(E) -> R
    ) throws(E) -> R {
        try unsafe Swift.withUnsafeBytes(of: cValue) { (buffer: UnsafeRawBufferPointer) throws(E) -> R in
            try unsafe body(buffer.baseAddress!, UInt32(buffer.count))
        }
    }

    /// Calls `body` with a mutable raw pointer to the underlying storage and its
    /// capacity in bytes. The closure should return the actual number of bytes
    /// written by the kernel.
    ///
    /// Used by syscall wrappers (accept, getsockname) that fill in an address.
    public mutating func withUnsafeMutableBytes<R, E: Swift.Error>(
        _ body: (UnsafeMutableRawPointer, UInt32) throws(E) -> R
    ) throws(E) -> R {
        try unsafe Swift.withUnsafeMutableBytes(of: &cValue) { (buffer: UnsafeMutableRawBufferPointer) throws(E) -> R in
            try unsafe body(buffer.baseAddress!, UInt32(buffer.count))
        }
    }
}
