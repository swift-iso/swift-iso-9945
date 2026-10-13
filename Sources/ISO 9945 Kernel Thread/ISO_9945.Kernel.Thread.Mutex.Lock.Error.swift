#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Thread.Mutex.Lock {

    public enum Error: Swift::Error, Sendable {

        case contention

        case platform(Error::Error.Code)
    }
}
