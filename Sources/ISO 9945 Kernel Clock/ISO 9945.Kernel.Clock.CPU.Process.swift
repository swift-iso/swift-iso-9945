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

extension Kernel.Clock.CPU {
    /// Process-wide CPU time (`CLOCK_PROCESS_CPUTIME_ID`, IEEE 1003.1-2001).
    ///
    /// Aggregates user + system CPU time across all threads in the process.
    /// A thread sleeping in the kernel does not contribute; a thread
    /// executing user code or a syscall does.
    public enum Process {}
}

extension Kernel.Clock.CPU.Process {
    /// Returns the process-wide CPU time consumed so far, in nanoseconds.
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
    /// let before = Kernel.Clock.CPU.Process.now()
    /// try await Task.sleep(for: .milliseconds(50))
    /// let after = Kernel.Clock.CPU.Process.now()
    /// // `after - before` is nanoseconds of CPU consumed during the sleep.
    /// // If no thread is working, expect ~0; a hot-spinning thread shows ~50ms.
    /// ```
    public static func now() -> UInt64 {
        var ts = timespec()
        _ = unsafe clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &ts)
        return UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
    }
}
