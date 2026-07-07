#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Poll {
    /// Bitmask of poll events.
    ///
    /// Used both to request events (input) and to report events (output).
    public struct Events: OptionSet, Sendable, Equatable, Hashable {
        public let rawValue: Int16

        public init(rawValue: Int16) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Requestable Events

extension ISO_9945.Kernel.Poll.Events {
    /// Data available for reading (POLLIN).
    public static let input = Self(rawValue: Int16(POLLIN))

    /// Urgent data available for reading (POLLPRI).
    public static let priority = Self(rawValue: Int16(POLLPRI))

    /// Writing is possible without blocking (POLLOUT).
    public static let output = Self(rawValue: Int16(POLLOUT))
}

// MARK: - Output-Only Events (set by kernel, not requestable)

extension ISO_9945.Kernel.Poll.Events {
    /// Error condition on the descriptor (POLLERR).
    ///
    /// Output only — always reported regardless of requested events.
    public static let error = Self(rawValue: Int16(POLLERR))

    /// Hang up on the descriptor (POLLHUP).
    ///
    /// Output only — indicates the peer closed the connection.
    public static let hangUp = Self(rawValue: Int16(POLLHUP))

    /// Invalid descriptor (POLLNVAL).
    ///
    /// Output only — the file descriptor is not open.
    public static let invalid = Self(rawValue: Int16(POLLNVAL))
}
