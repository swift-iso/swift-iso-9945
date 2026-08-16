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

/// POSIX implementation of Clock.Continuous and Clock.Suspending.

#if !os(Windows)

    // MARK: - Clock.Continuous POSIX Implementation

    extension Clock.Continuous: _Concurrency.Clock {
        /// The current instant according to the continuous clock.
        ///
        /// Delegates directly to `Clock.Continuous.now`, which wraps:
        /// - Darwin: `clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW)`
        /// - Linux: `clock_gettime(CLOCK_BOOTTIME)`
        public var now: Instant { Clock.Continuous.now }

        /// Suspends until the given deadline, checking for cancellation.
        ///
        /// Sleeps once for the remaining duration (re-checking after wake to
        /// handle early return) rather than polling — a one-second sleep
        /// consumes approximately no CPU. `tolerance` is forwarded to the
        /// underlying suspension.
        ///
        /// - Parameters:
        ///   - deadline: The instant to sleep until.
        ///   - tolerance: Optional tolerance for the wake-up.
        /// - Throws: `CancellationError` if the task is cancelled.
        nonisolated(nonsending)
            public func sleep(
                until deadline: Instant,
                tolerance: Duration? = nil
            ) async throws(CancellationError)
        {
            while true {
                let remaining = deadline - Clock.Continuous.now
                guard remaining > .zero else { return }
                do {
                    try Task.checkCancellation()
                    try await Task.sleep(for: remaining, tolerance: tolerance)
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    preconditionFailure(
                        "Task.sleep/checkCancellation contract violation: \(type(of: error))"
                    )
                }
            }
        }
    }

    // MARK: - Clock.Suspending POSIX Implementation

    extension Clock.Suspending: _Concurrency.Clock {
        /// The current instant according to the suspending clock.
        ///
        /// Delegates directly to `Clock.Suspending.now`, which wraps:
        /// - Darwin: `clock_gettime_nsec_np(CLOCK_UPTIME_RAW)`
        /// - Linux: `clock_gettime(CLOCK_MONOTONIC)`
        public var now: Instant { Clock.Suspending.now }

        /// Suspends until the given deadline, checking for cancellation.
        ///
        /// Sleeps once for the remaining duration (re-checking after wake to
        /// handle early return) rather than polling — a one-second sleep
        /// consumes approximately no CPU. `tolerance` is forwarded to the
        /// underlying suspension.
        ///
        /// - Parameters:
        ///   - deadline: The instant to sleep until.
        ///   - tolerance: Optional tolerance for the wake-up.
        /// - Throws: `CancellationError` if the task is cancelled.
        nonisolated(nonsending)
            public func sleep(
                until deadline: Instant,
                tolerance: Duration? = nil
            ) async throws(CancellationError)
        {
            while true {
                let remaining = deadline - Clock.Suspending.now
                guard remaining > .zero else { return }
                do {
                    try Task.checkCancellation()
                    try await Task.sleep(for: remaining, tolerance: tolerance)
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    preconditionFailure(
                        "Task.sleep/checkCancellation contract violation: \(type(of: error))"
                    )
                }
            }
        }
    }

#endif
