public import Kernel_Socket_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.Socket {
    /// Socket type.
    ///
    /// Specifies the communication semantics for a socket.
    public struct Kind: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Constants

extension Kernel.Socket.Kind {
    /// Sequenced, reliable, two-way, connection-based byte streams (SOCK_STREAM).
    public static let stream = Self(rawValue: Int32(SOCK_STREAM))

    /// Connectionless, unreliable messages of a fixed maximum length (SOCK_DGRAM).
    public static let datagram = Self(rawValue: Int32(SOCK_DGRAM))

    /// Raw network protocol access (SOCK_RAW).
    public static let raw = Self(rawValue: Int32(SOCK_RAW))

    /// Sequenced, reliable, two-way, connection-based datagrams (SOCK_SEQPACKET).
    public static let sequencedPacket = Self(rawValue: Int32(SOCK_SEQPACKET))
}
