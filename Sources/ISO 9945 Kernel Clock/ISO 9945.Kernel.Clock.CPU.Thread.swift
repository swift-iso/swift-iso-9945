#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Clock.CPU {

    public enum Thread {}
}

extension Clock.CPU.Thread {

    public typealias Instant = Clock.Instant<Clock.CPU.Thread>
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)
    extension Clock.CPU.Thread {

        public static func now() -> Instant {
            var ts = timespec()
            guard unsafe clock_gettime(CLOCK_THREAD_CPUTIME_ID, &ts) == 0,
                ts.tv_sec >= 0, ts.tv_nsec >= 0
            else {
                return Instant(offset: .nanoseconds(0))
            }
            let ns = UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
            return Instant(offset: .nanoseconds(ns))
        }
    }
#endif
