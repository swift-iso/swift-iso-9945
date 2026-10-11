#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Option {

    public struct Name: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Socket.Option.Name {

    public static let error = Self(rawValue: SO_ERROR)

    public static let reuseAddress = Self(rawValue: SO_REUSEADDR)

    public static let reusePort = Self(rawValue: SO_REUSEPORT)

    public static let keepAlive = Self(rawValue: SO_KEEPALIVE)

    public static let broadcast = Self(rawValue: SO_BROADCAST)

    public static let linger = Self(rawValue: SO_LINGER)

    public static let receiveBuffer = Self(rawValue: SO_RCVBUF)

    public static let sendBuffer = Self(rawValue: SO_SNDBUF)

    public static let receiveTimeout = Self(rawValue: SO_RCVTIMEO)

    public static let sendTimeout = Self(rawValue: SO_SNDTIMEO)

    public static let outOfBandInline = Self(rawValue: SO_OOBINLINE)

    #if canImport(Darwin)
        public static let noSIGPIPE = Self(rawValue: SO_NOSIGPIPE)
    #endif

    public static let type = Self(rawValue: SO_TYPE)

    #if canImport(Glibc) || canImport(Musl)
        public static let domain = Self(rawValue: SO_DOMAIN)
    #endif
}

extension ISO_9945.Kernel.Socket.Option.Name {

    public static let tcpNoDelay = Self(rawValue: TCP_NODELAY)

    public static let tcpMaxSegmentSize = Self(rawValue: TCP_MAXSEG)
}

extension ISO_9945.Kernel.Socket.Option.Name {

    public static let ipTimeToLive = Self(rawValue: IP_TTL)

    public static let ipTypeOfService = Self(rawValue: IP_TOS)
}

extension ISO_9945.Kernel.Socket.Option.Name {

    public static let ipv6UnicastHops = Self(rawValue: IPV6_UNICAST_HOPS)

    public static let ipv6Only = Self(rawValue: IPV6_V6ONLY)
}
