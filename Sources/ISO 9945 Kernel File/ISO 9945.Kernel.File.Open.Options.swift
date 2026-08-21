#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File.Open.Options {

    public static let create = Self(rawValue: O_CREAT)

    public static let truncate = Self(rawValue: O_TRUNC)

    public static let append = Self(rawValue: O_APPEND)

    public static let exclusive = Self(rawValue: O_EXCL)

    public static let execClose = Self(rawValue: O_CLOEXEC)

    public static let nonBlocking = Self(rawValue: O_NONBLOCK)

    public static let noFollow = Self(rawValue: O_NOFOLLOW)
}
