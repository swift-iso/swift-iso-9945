#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Pair.Error {

    public enum Platform: Sendable, Equatable {

        case posix(Int32)
    }
}
