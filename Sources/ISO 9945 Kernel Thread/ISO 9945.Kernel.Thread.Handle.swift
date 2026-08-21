#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Thread {

    @safe
    public struct Handle: ~Copyable, @unchecked Sendable {
        internal let rawValue: pthread_t

        internal init(rawValue: pthread_t) {
            unsafe (self.rawValue = rawValue)
        }
    }
}

extension ISO_9945.Kernel.Thread.Handle {

    public consuming func join() throws(ISO_9945.Kernel.Thread.Error) {
        let result = unsafe pthread_join(rawValue, nil)
        guard result == 0 else {
            throw .join(.posix(result))
        }
    }

    public consuming func detach() throws(ISO_9945.Kernel.Thread.Error) {
        let result = unsafe pthread_detach(rawValue)
        guard result == 0 else {
            throw .detach(.posix(result))
        }
    }

    public var isCurrent: Bool {
        unsafe (pthread_equal(pthread_self(), rawValue) != 0)
    }
}
