
#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.Socket.Address {
    /// Unix domain socket address.
    ///
    /// Wraps `sockaddr_un`.
    public struct Unix: @unchecked Sendable {
        internal var cValue: sockaddr_un

        /// Creates an empty Unix socket address.
        public init() {
            self.cValue = sockaddr_un()
            self.cValue.sun_family = sa_family_t(AF_UNIX)
        }
    }
}

// MARK: - Accessors

extension Kernel.Socket.Address.Unix {
    /// The address family (always `.unix`).
    public var family: Kernel.Socket.Address.Family {
        get { .unix }
    }
}

// MARK: - Storage Conversion

extension Kernel.Socket.Address.Unix {
    /// Converts to the generic `Storage` container.
    public var storage: Kernel.Socket.Address.Storage {
        var result = Kernel.Socket.Address.Storage()
        unsafe withUnsafePointer(to: cValue) { src in
            unsafe withUnsafeMutablePointer(to: &result.cValue) { dst in
                unsafe UnsafeMutableRawPointer(dst)
                    .copyMemory(from: src, byteCount: MemoryLayout<sockaddr_un>.size)
            }
        }
        return result
    }
}
