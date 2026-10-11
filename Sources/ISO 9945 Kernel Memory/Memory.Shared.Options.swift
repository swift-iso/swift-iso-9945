import Memory

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Memory.Shared {

    public struct Options: OptionSet, Sendable, Hashable {

        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension Memory.Shared.Options {

    public static let create = Self(rawValue: O_CREAT)

    public static let exclusive = Self(rawValue: O_EXCL)

    public static let truncate = Self(rawValue: O_TRUNC)
}
