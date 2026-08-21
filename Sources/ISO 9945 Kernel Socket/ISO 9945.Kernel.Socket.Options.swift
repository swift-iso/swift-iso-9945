#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Options {

    public static let nonBlock = Self(rawValue: Int32(O_NONBLOCK))

    public static let closeOnExec = Self(rawValue: Int32(O_CLOEXEC))

    public static let asyncDefault: Self = [.nonBlock, .closeOnExec]
}
