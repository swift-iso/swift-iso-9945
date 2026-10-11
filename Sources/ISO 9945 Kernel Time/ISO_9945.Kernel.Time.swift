#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Time {

    public static func realtime() -> ISO_9945.Kernel.Time {
        #if canImport(Darwin)
            var ts = Darwin.timespec()
        #elseif canImport(Musl)
            var ts = Musl.timespec()
        #elseif canImport(Glibc)
            var ts = Glibc.timespec()
        #endif
        unsafe clock_gettime(CLOCK_REALTIME, &ts)
        return ISO_9945.Kernel.Time(
            _unchecked: (),
            secondsSinceUnixEpoch: Int64(ts.tv_sec),
            nanosecondFraction: Int32(ts.tv_nsec)
        )
    }
}
