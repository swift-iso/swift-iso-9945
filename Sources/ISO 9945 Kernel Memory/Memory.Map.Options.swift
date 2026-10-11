import Memory

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Memory.Map.Options {

    public static let shared = Self(rawValue: MAP_SHARED)

    public static let `private` = Self(rawValue: MAP_PRIVATE)

    public static let anonymous = Self(rawValue: MAP_ANON)

    public static let fixed = Self(rawValue: MAP_FIXED)
}
