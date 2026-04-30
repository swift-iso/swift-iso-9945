
#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Address {
    /// Socket address family.
    public struct Family: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Constants

extension ISO_9945.Kernel.Socket.Address.Family {
    /// IPv4 internet protocols.
    public static let inet = Self(rawValue: Int32(AF_INET))

    /// IPv6 internet protocols.
    public static let inet6 = Self(rawValue: Int32(AF_INET6))

    /// Unix domain sockets.
    public static let unix = Self(rawValue: Int32(AF_UNIX))

    /// Unspecified.
    public static let unspecified = Self(rawValue: Int32(AF_UNSPEC))
}
