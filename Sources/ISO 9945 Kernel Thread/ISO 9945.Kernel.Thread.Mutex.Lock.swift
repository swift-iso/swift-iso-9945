#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Thread.Mutex {

    public struct Lock: Sendable {
        let mutex: ISO_9945.Kernel.Thread.Mutex
    }
}

extension ISO_9945.Kernel.Thread.Mutex.Lock {

    public enum Error: Swift.Error, Sendable {

        case contention

        case platform(Error.Error.Code)
    }
}

extension ISO_9945.Kernel.Thread.Mutex.Lock {

    public func callAsFunction() {
        mutex.acquireBlocking()
    }

    public func immediate() throws(Error) {
        let result = mutex.tryAcquire()
        guard result != 0 else { return }
        guard result == EBUSY else {
            throw .platform(.posix(result))
        }
        throw .contention
    }
}
