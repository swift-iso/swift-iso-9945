#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Clock.Continuous {

    public static var now: Clock.Continuous.Instant {
        #if canImport(Darwin)
            let ns = clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW)
        #elseif canImport(Musl)
            var ts = Musl.timespec()
            clock_gettime(CLOCK_BOOTTIME, &ts)
            let ns = UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
        #elseif canImport(Glibc)
            var ts = Glibc.timespec()
            clock_gettime(CLOCK_BOOTTIME, &ts)
            let ns = UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
        #endif
        return Clock.Continuous.Instant(nanoseconds: ns)
    }
}

extension Clock.Suspending {

    public static var now: Clock.Suspending.Instant {
        #if canImport(Darwin)
            let ns = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
        #elseif canImport(Musl)
            var ts = Musl.timespec()
            clock_gettime(CLOCK_MONOTONIC, &ts)
            let ns = UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
        #elseif canImport(Glibc)
            var ts = Glibc.timespec()
            clock_gettime(CLOCK_MONOTONIC, &ts)
            let ns = UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
        #endif
        return Clock.Suspending.Instant(nanoseconds: ns)
    }
}
