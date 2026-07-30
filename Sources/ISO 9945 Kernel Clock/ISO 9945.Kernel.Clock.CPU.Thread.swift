// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
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

extension Clock.CPU {
    /// Calling-thread CPU time (`CLOCK_THREAD_CPUTIME_ID`, IEEE 1003.1-2001).
    ///
    /// Counts user and system CPU time consumed only by the calling thread.
    /// Time spent sleeping or blocked in the kernel does not contribute.
    public enum Thread {}
}

extension Clock.CPU.Thread {
    /// A phantom-tagged instant on the calling-thread CPU clock.
    ///
    /// Type-distinct from process-wide CPU time and wall-clock time.
    public typealias Instant = Tagged<Clock.CPU.Thread, Clock.Nanoseconds>
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)
    extension Clock.CPU.Thread {
        /// Returns the current instant on the calling-thread CPU clock.
        ///
        /// Wraps `clock_gettime(CLOCK_THREAD_CPUTIME_ID)` directly — Swift
        /// expresses the call, so no C shim is involved. A failed clock
        /// read reports the clock epoch (zero nanoseconds), the same
        /// explicit rule as `Clock.CPU.Process.now()`.
        public static func now() -> Instant {
            var ts = timespec()
            guard unsafe clock_gettime(CLOCK_THREAD_CPUTIME_ID, &ts) == 0,
                ts.tv_sec >= 0, ts.tv_nsec >= 0
            else {
                return Instant(nanoseconds: 0)
            }
            let ns = UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
            return Instant(nanoseconds: ns)
        }
    }
#endif
