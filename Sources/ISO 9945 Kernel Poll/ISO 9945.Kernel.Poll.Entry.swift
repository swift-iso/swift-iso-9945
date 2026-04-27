#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Poll {
    /// A poll entry describing a file descriptor and its requested/returned events.
    ///
    /// Wraps `struct pollfd`. Layout-compatible for direct use with the `poll` syscall.
    public struct Entry: Sendable {
        /// The underlying C struct.
        internal var cValue: pollfd

        /// Creates a poll entry (raw-Int32 descriptor variant).
        ///
        /// - Parameters:
        ///   - descriptor: The raw file descriptor to monitor.
        ///   - requested: Events to monitor for.
        @_spi(Syscall)
        public init(descriptor: Int32, requested: Events) {
            self.cValue = pollfd(
                fd: descriptor,
                events: requested.rawValue,
                revents: 0
            )
        }
    }
}

// MARK: - Accessors

extension ISO_9945.Kernel.Poll.Entry {
    /// The raw file descriptor being monitored.
    @_spi(Syscall)
    public var descriptor: Int32 {
        get { cValue.fd }
        set { cValue.fd = newValue }
    }

    /// Events requested for monitoring.
    public var requested: ISO_9945.Kernel.Poll.Events {
        get { ISO_9945.Kernel.Poll.Events(rawValue: cValue.events) }
        set { cValue.events = newValue.rawValue }
    }

    /// Events returned by the kernel after poll.
    public var returned: ISO_9945.Kernel.Poll.Events {
        ISO_9945.Kernel.Poll.Events(rawValue: cValue.revents)
    }
}
