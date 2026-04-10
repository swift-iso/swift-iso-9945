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

    /// Gets the current wall-clock time as seconds since Unix epoch.
    ///
    /// Uses `CLOCK_REALTIME` which tracks real-world time. Subject to
    /// NTP adjustments and manual clock changes — NOT suitable for
    /// elapsed time measurement. Use for timestamps and record-keeping.
    ///
    /// - Returns: Seconds since 1970-01-01 00:00:00 UTC (with microsecond precision).
    public static func realtimeEpochSeconds() -> Double {
        #if canImport(Darwin)
            var tv = Darwin.timeval()
        #elseif canImport(Musl)
            var tv = Musl.timeval()
        #elseif canImport(Glibc)
            var tv = Glibc.timeval()
        #endif
        unsafe gettimeofday(&tv, nil)
        return Double(tv.tv_sec) + Double(tv.tv_usec) / 1_000_000.0
    }
}
