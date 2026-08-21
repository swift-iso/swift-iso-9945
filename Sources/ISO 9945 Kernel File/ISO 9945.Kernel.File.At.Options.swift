#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File.At {

    public struct Options: OptionSet, Sendable {

        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.File.At.Options {

    public static let noFollow = Self(rawValue: Int32(AT_SYMLINK_NOFOLLOW))

    public static let symlinkFollow = Self(rawValue: Int32(AT_SYMLINK_FOLLOW))

    public static let removeDirectory = Self(rawValue: Int32(AT_REMOVEDIR))
}
