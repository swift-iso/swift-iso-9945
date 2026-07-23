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

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)
    internal import CISO9945Shim
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
    public static func now() -> Instant {
        Instant(
            nanoseconds: iso9945_clock_thread_cpu_time_nanoseconds()
        )
    }
}
#endif
