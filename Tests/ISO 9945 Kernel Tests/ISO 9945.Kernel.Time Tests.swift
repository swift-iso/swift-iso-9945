import ISO_9945_Kernel
import Testing

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

@Suite
struct `Kernel Time Tests` {
    @Suite struct Unit {}
}

extension `Kernel Time Tests`.Unit {
    private static func clockRealtimeSeconds() -> Int64 {
        var ts = timespec()
        unsafe clock_gettime(CLOCK_REALTIME, &ts)
        return Int64(ts.tv_sec)
    }

    @Test
    func `POSIX.1-2024 clock_gettime CLOCK_REALTIME reading lies between two direct readings`() {
        let before = Self.clockRealtimeSeconds()
        let instant = ISO_9945.Kernel.Time.realtime()
        let after = Self.clockRealtimeSeconds()
        #expect(instant.secondsSinceUnixEpoch >= before)
        #expect(instant.secondsSinceUnixEpoch <= after)
    }

    @Test
    func `POSIX.1-2024 CLOCK_REALTIME nanosecond fraction is within zero to one second`() {
        let instant = ISO_9945.Kernel.Time.realtime()
        #expect(instant.nanosecondFraction >= 0)
        #expect(instant.nanosecondFraction < 1_000_000_000)
    }
}
