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

@_spi(Syscall) public import Kernel_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
    internal import CLinuxShim
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

    /// Gets the current monotonic time in nanoseconds.
    ///
    /// Uses `CLOCK_MONOTONIC` which is not affected by system time changes.
    /// This is suitable for measuring elapsed time and deadlines.
    ///
    /// - Returns: Nanoseconds since an arbitrary fixed point in time.

    public static func monotonicNanoseconds() -> UInt64 {
        #if canImport(Darwin)
            var ts = Darwin.timespec()
        #elseif canImport(Musl)
            var ts = Musl.timespec()
        #elseif canImport(Glibc)
            var ts = Glibc.timespec()
        #endif
        clock_gettime(CLOCK_MONOTONIC, &ts)
        return UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
    }
}
