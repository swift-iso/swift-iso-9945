@_spi(Syscall) import Kernel_Socket_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Option {
    /// Socket option level.
    public struct Level: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Constants

extension ISO_9945.Kernel.Socket.Option.Level {
    /// Socket-level options (SOL_SOCKET).
    public static let socket = Self(rawValue: SOL_SOCKET)

    /// TCP-level options (IPPROTO_TCP).
    public static let tcp = Self(rawValue: Int32(IPPROTO_TCP))

    /// IPv4-level options (IPPROTO_IP).
    public static let ip = Self(rawValue: Int32(IPPROTO_IP))

    /// IPv6-level options (IPPROTO_IPV6).
    public static let ipv6 = Self(rawValue: Int32(IPPROTO_IPV6))
}
