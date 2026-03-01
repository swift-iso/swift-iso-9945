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
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX clock operations

extension ISO_9945.Kernel.Clock.Continuous {
    /// Returns the current continuous time in nanoseconds since boot.
    ///
    /// - Darwin: Uses `CLOCK_MONOTONIC_RAW` which advances during system sleep
    ///   and is immune to NTP frequency adjustments. (`CLOCK_MONOTONIC` on Darwin
    ///   can violate monotonicity on system time changes — the Swift stdlib and Rust
    ///   both use `CLOCK_MONOTONIC_RAW` to avoid this.)
    /// - Linux: Uses `CLOCK_BOOTTIME` which advances during system sleep.

    public static func now() -> UInt64 {
        #if canImport(Darwin)
        return clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW)
        #elseif canImport(Musl)
        var ts = Musl.timespec()
        clock_gettime(CLOCK_BOOTTIME, &ts)
        return UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
        #elseif canImport(Glibc)
        var ts = Glibc.timespec()
        clock_gettime(CLOCK_BOOTTIME, &ts)
        return UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
        #endif
    }
}

extension ISO_9945.Kernel.Clock.Suspending {
    /// Returns the current suspending time in nanoseconds since boot.
    ///
    /// - Darwin: Uses `CLOCK_UPTIME_RAW` which pauses during system sleep.
    /// - Linux: Uses `CLOCK_MONOTONIC` which pauses during system sleep.

    public static func now() -> UInt64 {
        #if canImport(Darwin)
        return clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
        #elseif canImport(Musl)
        var ts = Musl.timespec()
        clock_gettime(CLOCK_MONOTONIC, &ts)
        return UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
        #elseif canImport(Glibc)
        var ts = Glibc.timespec()
        clock_gettime(CLOCK_MONOTONIC, &ts)
        return UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
        #endif
    }
}
