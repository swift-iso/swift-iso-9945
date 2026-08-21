@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Poll {

    public struct Entry: Sendable {

        internal var cValue: pollfd

        internal init(descriptor: Int32, requested: Events) {
            self.cValue = pollfd(
                fd: descriptor,
                events: requested.rawValue,
                revents: 0
            )
        }
    }
}

extension ISO_9945.Kernel.Poll.Entry {

    @_spi(Syscall)
    public var descriptor: Int32 {
        get { cValue.fd }
        set { cValue.fd = newValue }
    }

    public var requested: ISO_9945.Kernel.Poll.Events {
        get { ISO_9945.Kernel.Poll.Events(rawValue: cValue.events) }
        set { cValue.events = newValue.rawValue }
    }

    public var returned: ISO_9945.Kernel.Poll.Events {
        ISO_9945.Kernel.Poll.Events(rawValue: cValue.revents)
    }
}

extension ISO_9945.Kernel.Poll.Entry {

    public init(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        requested: ISO_9945.Kernel.Poll.Events
    ) {
        self.init(descriptor: descriptor._rawValue, requested: requested)
    }
}
