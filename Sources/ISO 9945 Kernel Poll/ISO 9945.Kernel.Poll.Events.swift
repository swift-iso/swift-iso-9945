#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Poll {

    public struct Events: OptionSet, Sendable, Equatable, Hashable {
        public let rawValue: Int16

        public init(rawValue: Int16) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Poll.Events {

    public static let input = Self(rawValue: Int16(POLLIN))

    public static let priority = Self(rawValue: Int16(POLLPRI))

    public static let output = Self(rawValue: Int16(POLLOUT))
}

extension ISO_9945.Kernel.Poll.Events {

    public static let error = Self(rawValue: Int16(POLLERR))

    public static let hangUp = Self(rawValue: Int16(POLLHUP))

    public static let invalid = Self(rawValue: Int16(POLLNVAL))
}
