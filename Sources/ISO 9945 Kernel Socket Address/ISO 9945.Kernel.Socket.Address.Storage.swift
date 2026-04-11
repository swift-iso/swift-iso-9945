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
}
