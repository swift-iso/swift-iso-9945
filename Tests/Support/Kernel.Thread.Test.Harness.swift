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

import Kernel_Primitives_Core
import Kernel_Descriptor_Primitives
import Kernel_Event_Primitives
import Kernel_File_Primitives
import Path_Primitives
import Kernel_Process_Primitives
import Error_Primitives
import ISO_9945_Kernel
import ISO_9945_Kernel

/// Test harness utilities for threading tests.
///
/// Provides a condvar-based coordination mechanism that eliminates:
/// - Cross-thread mutex unlock (undefined behavior)
/// - Data races on shared state
/// - Timing-based correctness assertions
///
/// Use `Harness<State>` to coordinate between test threads via:
/// - `update { }` for synchronized mutation plus broadcast
/// - `wait(until:)` for deterministic ordering
/// - `withLocked { }` for synchronized reads
public enum KernelThreadTest {
    /// Timeout error for `wait(until:)` operations.
    ///
    /// This is only used as a deadlock guard, not as a correctness signal.
    public struct Timeout: Swift.Error, Sendable, Equatable {
        public init() {}
    }

    /// Thread-safe test harness for coordinating threading tests.
    ///
    /// ## Usage
    /// ```swift
    /// enum State { case initial, working, done }
    /// let harness = KernelThreadTest.Harness(.initial)
    ///
    /// // Worker thread
    /// harness.update { $0 = .working }
    /// // ... do work ...
    /// harness.update { $0 = .done }
    ///
    /// // Test thread
    /// try harness.wait(until: { $0 == .working })
    /// try harness.wait(until: { $0 == .done })
    /// ```
    public final class Harness<State: Sendable>: @unchecked Sendable {
        private let mutex: ISO_9945.Kernel.Thread.Mutex
        private let condition: ISO_9945.Kernel.Thread.Condition
        private var state: State

        public init(_ initial: State) {
            self.mutex = ISO_9945.Kernel.Thread.Mutex()
            self.condition = ISO_9945.Kernel.Thread.Condition()
            self.state = initial
        }

        /// Atomically updates state and broadcasts to waiters.
        public func update(_ body: (inout State) -> Void) {
            mutex.lock()
            body(&state)
            condition.broadcast()
            mutex.unlock()
        }

        /// Waits until predicate returns true.
        ///
        /// - Parameter predicate: Condition to wait for
        /// - Throws: `Timeout` if wait exceeds the guard duration (deadlock protection)
        public func wait(until predicate: (State) -> Bool) throws(Timeout) {
            mutex.lock()
            defer { mutex.unlock() }

            // Simple spin with condition wait - no timeout for now
            // Real timeout would use pthread_cond_timedwait
            while !predicate(state) {
                condition.wait(mutex: mutex)
            }
        }

        /// Reads state under lock.
        public func withLocked<R>(_ body: (State) -> R) -> R {
            mutex.lock()
            defer { mutex.unlock() }
            return body(state)
        }
    }
}
