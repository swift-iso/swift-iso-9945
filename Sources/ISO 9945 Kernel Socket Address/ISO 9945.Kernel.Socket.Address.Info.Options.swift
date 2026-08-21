#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Address.Info {

    public struct Options: OptionSet, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Socket.Address.Info.Options {

    public static let passive = Self(rawValue: AI_PASSIVE)

    public static let canonicalName = Self(rawValue: AI_CANONNAME)

    public static let numericHost = Self(rawValue: AI_NUMERICHOST)

    public static let numericService = Self(rawValue: AI_NUMERICSERV)

    public static let v4Mapped = Self(rawValue: AI_V4MAPPED)

    public static let all = Self(rawValue: AI_ALL)

    public static let addressConfiguration = Self(rawValue: AI_ADDRCONFIG)
}
