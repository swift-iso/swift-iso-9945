#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Thread {

    public final class Mutex: @unchecked Sendable {
        private var mutex: pthread_mutex_t

        public init() {
            self.mutex = pthread_mutex_t()
            var attr = pthread_mutexattr_t()
            unsafe pthread_mutexattr_init(&attr)
            let result = unsafe pthread_mutex_init(&self.mutex, &attr)
            unsafe pthread_mutexattr_destroy(&attr)
            precondition(result == 0, "pthread_mutex_init failed with code \(result)")
        }

        deinit {
            unsafe pthread_mutex_destroy(&mutex)
        }
    }
}

extension ISO_9945.Kernel.Thread.Mutex {

    public func unlock() {
        let result = unsafe pthread_mutex_unlock(&mutex)
        precondition(result == 0, "pthread_mutex_unlock failed with code \(result)")
    }

    public var lock: Lock { Lock(mutex: self) }
}

extension ISO_9945.Kernel.Thread.Mutex {

    func acquireBlocking() {
        let result = unsafe pthread_mutex_lock(&mutex)
        precondition(result == 0, "pthread_mutex_lock failed with code \(result)")
    }

    func tryAcquire() -> Int32 {
        unsafe pthread_mutex_trylock(&mutex)
    }

    public func withLock<T, E: Swift.Error>(_ body: () throws(E) -> T) throws(E) -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}

extension ISO_9945.Kernel.Thread.Mutex {

    func withUnsafeMutablePointer<T>(_ body: (UnsafeMutablePointer<pthread_mutex_t>) -> T) -> T {
        Swift.withUnsafeMutablePointer(to: &mutex, body)
    }
}
