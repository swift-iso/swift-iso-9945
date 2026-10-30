public import Time

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif


extension Time.Zone.Rule {

    /// The process's local time zone, as `localtime_r` gives it (`tm_gmtoff`): the zone the `TZ` variable names, or the
    /// system's own when it is unset. `TZ` is read again at every instant asked for, so a change to it takes effect at
    /// once.
    public static let local = Self { instant in
        tzset()
        var seconds = time_t(instant.secondsSinceUnixEpoch)
        #if canImport(Darwin)
            var broken = Darwin.tm()
        #elseif canImport(Musl)
            var broken = Musl.tm()
        #elseif canImport(Glibc)
            var broken = Glibc.tm()
        #endif
        guard unsafe localtime_r(&seconds, &broken) != nil else { return .utc }
        return .seconds(Int(broken.tm_gmtoff))
    }
}
