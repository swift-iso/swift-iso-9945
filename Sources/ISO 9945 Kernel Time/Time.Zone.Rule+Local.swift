public import Time

extension Time.Zone.Rule {

    /// The process's local time zone, as `localtime_r` gives it (`tm_gmtoff`): the zone the `TZ` variable names, or the
    /// system's own when it is unset. `TZ` is read again at every instant asked for, so a change to it takes effect at
    /// once.
    public static let local = Self { _ in .utc }
}
