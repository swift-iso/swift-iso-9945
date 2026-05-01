
@_spi(Syscall) import ISO_9945_Core

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
        internal init(descriptor: Int32, requested: Events) {
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

// MARK: - Typed Convenience Initializer (Phase 1.5)

extension ISO_9945.Kernel.Poll.Entry {
    /// Creates a poll entry from a typed `ISO_9945.Kernel.Descriptor`.
    ///
    /// Phase 1.5 typed L2 form. The raw `init(descriptor: Int32, ...)` SPI
    /// form is retained for spec-coverage callers; this typed form delegates
    /// to it via `descriptor._rawValue` (the @_spi(Syscall) accessor on the
    /// L1 type).
    ///
    /// - Parameters:
    ///   - descriptor: The descriptor to monitor.
    ///   - requested: Events to monitor for.
    public init(_ descriptor: borrowing ISO_9945.Kernel.Descriptor, requested: ISO_9945.Kernel.Poll.Events) {
        self.init(descriptor: descriptor._rawValue, requested: requested)
    }
}
