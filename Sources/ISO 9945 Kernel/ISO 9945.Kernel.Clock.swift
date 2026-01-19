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
    /// - Darwin: Uses `CLOCK_MONOTONIC` which advances during system sleep.
    /// - Linux: Uses `CLOCK_BOOTTIME` which advances during system sleep.

    public static func now() -> UInt64 {
        #if canImport(Darwin)
        var ts = Darwin.timespec()
        clock_gettime(CLOCK_MONOTONIC, &ts)
        #elseif canImport(Musl)
        var ts = Musl.timespec()
        clock_gettime(CLOCK_BOOTTIME, &ts)
        #elseif canImport(Glibc)
        var ts = Glibc.timespec()
        clock_gettime(CLOCK_BOOTTIME, &ts)
        #endif
        return UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
    }
}

extension ISO_9945.Kernel.Clock.Suspending {
    /// Returns the current suspending time in nanoseconds since boot.
    ///
    /// - Darwin: Uses `CLOCK_UPTIME_RAW` which pauses during system sleep.
    /// - Linux: Uses `CLOCK_MONOTONIC` which pauses during system sleep.

    public static func now() -> UInt64 {
        #if canImport(Darwin)
        var ts = Darwin.timespec()
        clock_gettime(CLOCK_UPTIME_RAW, &ts)
        #elseif canImport(Musl)
        var ts = Musl.timespec()
        clock_gettime(CLOCK_MONOTONIC, &ts)
        #elseif canImport(Glibc)
        var ts = Glibc.timespec()
        clock_gettime(CLOCK_MONOTONIC, &ts)
        #endif
        return UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
    }
}
