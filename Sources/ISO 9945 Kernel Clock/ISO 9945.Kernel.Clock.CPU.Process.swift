// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
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
    /// Process-wide CPU time (`CLOCK_PROCESS_CPUTIME_ID`, IEEE 1003.1-2001).
    ///
    /// Aggregates user + system CPU time across all threads in the process.
    /// A thread sleeping in the kernel does not contribute; a thread
    /// executing user code or a syscall does.
    public enum Process {}
}

extension Clock.CPU.Process {
    /// A phantom-tagged instant on the process-wide CPU clock.
    ///
    /// Type-distinct from `Clock.Continuous.Instant` and
    /// `Clock.Suspending.Instant`: mixing CPU-time with wall-clock time
    /// is a compile error.
    public typealias Instant = Tagged<Clock.CPU.Process, Clock.Nanoseconds>
}

extension Clock.CPU.Process {
    /// Returns the current instant on the process-wide CPU clock.
    ///
    /// Wraps `clock_gettime(CLOCK_PROCESS_CPUTIME_ID)`. Available on all
    /// Darwin versions this ecosystem targets and on glibc-based Linux
    /// distributions (Ubuntu jammy / noble / trixie — i.e., the
    /// `swift:6.3` Docker base image used by swift-io's Linux gate).
    ///
    /// ## Use case
    ///
    /// Measure CPU consumption across a known-idle interval to prove that
    /// a thread is sleeping in the kernel rather than hot-spinning. A
    /// thread blocked in `accept(2)`, `poll(2)`, or `epoll_wait(2)` shows
    /// near-zero CPU delta; a thread spinning in a retry loop shows CPU
    /// delta approaching wall-clock delta.
    ///
    /// ```swift
    /// let before = Clock.CPU.Process.now()
    /// try await Task.sleep(for: .milliseconds(50))
    /// let after = Clock.CPU.Process.now()
    /// let delta: Duration = after - before
    /// // If no thread is working, expect ~.zero;
    /// // a hot-spinning thread shows ~.milliseconds(50).
    /// ```
    public static func now() -> Instant {
        var ts = timespec()
        _ = unsafe clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &ts)
        let ns = UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
        return Instant(nanoseconds: ns)
    }
}
