#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Thread {

    @safe
    public final class Condition: @unchecked Sendable {
        private var cond: pthread_cond_t

        public init() {
            self.cond = pthread_cond_t()
            var attr = pthread_condattr_t()
            unsafe pthread_condattr_init(&attr)
            #if !os(macOS) && !os(iOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
                unsafe pthread_condattr_setclock(&attr, CLOCK_MONOTONIC)
            #endif
            unsafe pthread_cond_init(&self.cond, &attr)
            unsafe pthread_condattr_destroy(&attr)
        }

        deinit {
            unsafe pthread_cond_destroy(&cond)
        }
    }
}

extension ISO_9945.Kernel.Thread.Condition {

    public func wait(mutex: ISO_9945.Kernel.Thread.Mutex) {
        _ = unsafe mutex.withUnsafeMutablePointer { mutexPtr in
            unsafe pthread_cond_wait(&cond, mutexPtr)
        }
    }

    public func wait(mutex: ISO_9945.Kernel.Thread.Mutex, timeout: Duration) -> Bool {
        unsafe mutex.withUnsafeMutablePointer { mutexPtr in
            let (seconds, attoseconds) = timeout.components
            var ts = timespec()
            #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
                ts.tv_sec = Int(seconds)
                ts.tv_nsec = Int(attoseconds / 1_000_000_000)
                let result = unsafe pthread_cond_timedwait_relative_np(&cond, mutexPtr, &ts)
            #else
                clock_gettime(CLOCK_MONOTONIC, &ts)
                ts.tv_sec += Int(seconds)
                ts.tv_nsec += Int(attoseconds / 1_000_000_000)
                if ts.tv_nsec >= 1_000_000_000 {
                    ts.tv_sec += 1
                    ts.tv_nsec -= 1_000_000_000
                }
                let result = unsafe pthread_cond_timedwait(&cond, mutexPtr, &ts)
            #endif
            return result == 0
        }
    }
}

extension ISO_9945.Kernel.Thread.Condition {

    public func signal() {
        unsafe pthread_cond_signal(&cond)
    }

    public func broadcast() {
        unsafe pthread_cond_broadcast(&cond)
    }
}
