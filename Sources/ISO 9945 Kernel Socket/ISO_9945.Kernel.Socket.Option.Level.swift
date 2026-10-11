#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Option {

    public struct Level: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Socket.Option.Level {

    public static let socket = Self(rawValue: SOL_SOCKET)

    public static let tcp = Self(rawValue: Int32(IPPROTO_TCP))

    public static let ip = Self(rawValue: Int32(IPPROTO_IP))

    public static let ipv6 = Self(rawValue: Int32(IPPROTO_IPV6))
}
