import Memory

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Memory.Map.Protection {

    public static let read = Self(rawValue: PROT_READ)

    public static let write = Self(rawValue: PROT_WRITE)

    public static let execute = Self(rawValue: PROT_EXEC)

    public static let readWrite = read | write
}
