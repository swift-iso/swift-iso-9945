#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Address {
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

extension ISO_9945.Kernel.Socket.Address.Unix {
    /// The address family (always `.unix`).
    public var family: ISO_9945.Kernel.Socket.Address.Family {
        .unix
    }

    /// The size of the underlying sockaddr_un structure.
    public static var size: ISO_9945.Kernel.Socket.Address.Length {
        ISO_9945.Kernel.Socket.Address.Length(UInt(MemoryLayout<sockaddr_un>.size))
    }
}

// MARK: - Storage Conversion

extension ISO_9945.Kernel.Socket.Address.Unix {
    /// Converts to the generic `Storage` container.
    public var storage: ISO_9945.Kernel.Socket.Address.Storage {
        var result = ISO_9945.Kernel.Socket.Address.Storage()
        unsafe withUnsafePointer(to: cValue) { src in
            unsafe withUnsafeMutablePointer(to: &result.cValue) { dst in
                unsafe UnsafeMutableRawPointer(dst)
                    .copyMemory(from: src, byteCount: MemoryLayout<sockaddr_un>.size)
            }
        }
        return result
    }
}
