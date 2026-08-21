#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket {

    public struct Kind: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Socket.Kind {

    #if canImport(Glibc)
        public static let stream = Self(rawValue: Int32(SOCK_STREAM.rawValue))
    #else
        public static let stream = Self(rawValue: Int32(SOCK_STREAM))
    #endif

    #if canImport(Glibc)
        public static let datagram = Self(rawValue: Int32(SOCK_DGRAM.rawValue))
    #else
        public static let datagram = Self(rawValue: Int32(SOCK_DGRAM))
    #endif

    #if canImport(Glibc)
        public static let raw = Self(rawValue: Int32(SOCK_RAW.rawValue))
    #else
        public static let raw = Self(rawValue: Int32(SOCK_RAW))
    #endif

    #if canImport(Glibc)
        public static let sequencedPacket = Self(rawValue: Int32(SOCK_SEQPACKET.rawValue))
    #else
        public static let sequencedPacket = Self(rawValue: Int32(SOCK_SEQPACKET))
    #endif
}
