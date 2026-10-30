import ISO_9945_Kernel
import Testing
import Time

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

@Suite(.serialized)
struct `Kernel Time Zone Tests` {
    @Suite(.serialized) struct Unit {}
}

extension `Kernel Time Zone Tests`.Unit {
    /// Runs `body` with `TZ` set to `zone`, then puts `TZ` back as it was.
    private static func with(zone: Swift.String, _ body: () -> Void) {
        let previous = unsafe getenv("TZ").map { unsafe Swift.String(cString: $0) }
        unsafe setenv("TZ", zone, 1)
        defer {
            if let previous { unsafe setenv("TZ", previous, 1) } else { unsafe unsetenv("TZ") }
        }
        body()
    }

    @Test
    func `POSIX.1-2024 localtime_r in a zone without an offset gives UTC`() {
        Self.with(zone: "UTC0") {
            let zone = Time.Zone.Rule.local.offset(at: ISO_9945.Kernel.Time.realtime())
            #expect(zone.isUTC)
        }
    }

    @Test
    func `POSIX.1-2024 localtime_r gives the offset east of UTC, the inverse of the TZ sign`() {
        Self.with(zone: "XXX-2") {
            let zone = Time.Zone.Rule.local.offset(at: ISO_9945.Kernel.Time.realtime())
            #expect(zone.hours == 2)
            #expect(zone.minutes == 0)
        }
    }

    @Test
    func `POSIX.1-2024 localtime_r reads TZ again when it changes`() {
        Self.with(zone: "XXX+5:30") {
            let zone = Time.Zone.Rule.local.offset(at: ISO_9945.Kernel.Time.realtime())
            #expect(zone.hours == -5)
            #expect(zone.minutes == 30)
        }
    }
}
