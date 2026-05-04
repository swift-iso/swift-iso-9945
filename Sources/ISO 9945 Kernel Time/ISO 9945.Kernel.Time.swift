// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX Time Operations

extension ISO_9945.Kernel.Time {
    /// Converts a Duration to a POSIX timespec for kqueue/nanosleep.
    ///
    /// - Parameter duration: The duration to convert, or `nil` for infinite wait.
    /// - Returns: A `timespec` struct, or `nil` for infinite wait.
    ///
    /// This is a pure conversion function with no policy decisions.

    internal static func timespec(from duration: Duration?) -> timespec? {
        guard let duration else { return nil }
        let (seconds, attoseconds) = duration.components
        let nanoseconds = attoseconds / 1_000_000_000
        #if canImport(Darwin)
            return Darwin.timespec(tv_sec: Int(seconds), tv_nsec: Int(nanoseconds))
        #elseif canImport(Musl)
            return Musl.timespec(tv_sec: Int(seconds), tv_nsec: Int(nanoseconds))
        #elseif canImport(Glibc)
            return Glibc.timespec(tv_sec: Int(seconds), tv_nsec: Int(nanoseconds))
        #endif
    }

    /// Gets the current wall-clock time as a typed `ISO_9945.Kernel.Time`.
    ///
    /// Uses `clock_gettime(CLOCK_REALTIME, ...)` which tracks real-world time.
    /// Subject to NTP adjustments and manual clock changes — NOT suitable for
    /// elapsed time measurement. Use for timestamps and record-keeping.
    ///
    /// - Returns: The current wall-clock reading as seconds and nanoseconds
    ///   since 1970-01-01 00:00:00 UTC (nanosecond precision).
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
