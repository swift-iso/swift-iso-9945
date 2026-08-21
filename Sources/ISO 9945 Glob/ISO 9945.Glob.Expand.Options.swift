#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Glob.Expand {

    public struct Options: OptionSet, Sendable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Glob.Expand.Options {

    public static let err = Self(rawValue: GLOB_ERR)

    public static let mark = Self(rawValue: GLOB_MARK)

    public static let nosort = Self(rawValue: GLOB_NOSORT)

    public static let nocheck = Self(rawValue: GLOB_NOCHECK)

    public static let noescape = Self(rawValue: GLOB_NOESCAPE)
}
