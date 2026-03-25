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

// MARK: - POSIX Atomic Flag

extension CPU.Atomic {
    /// A one-way atomic boolean flag for cross-thread signaling.
    ///
    /// Flag provides a minimal, policy-free primitive for signaling between
    /// threads. Once set, a flag cannot be cleared - this is intentional
    /// to avoid race conditions and ensure deterministic behavior.
    ///
    /// ## Memory Ordering
    /// - `isSet` uses acquiring semantics (sees all writes before `set()`)
    /// - `set()` uses releasing semantics (all prior writes become visible)
    ///
    /// ## Usage
    /// ```swift
    /// let shutdown = CPU.Atomic.Flag()
    ///
    /// // Thread A: signal shutdown
    /// shutdown.set()
    ///
    /// // Thread B: check shutdown
    /// while !shutdown.isSet {
    ///     // do work
    /// }
    /// ```
    ///
    /// ## Thread Safety
    /// Flag is safe to share across threads without additional synchronization.
    /// Uses `@unchecked Sendable` because internal state is protected by
    /// atomic operations with acquire/release memory ordering.
    public final class Flag: @unchecked Sendable {
        @usableFromInline
        var _value: UInt8

        /// Creates a new flag with the given initial value.
        ///
        /// - Parameter initialValue: The initial state of the flag. Defaults to `false`.

        public init(_ initialValue: Bool = false) {
            self._value = initialValue ? 1 : 0
        }

        /// Whether the flag has been set.
        ///
        /// Uses acquiring memory ordering to ensure visibility of all
        /// writes that happened before `set()` was called.

        public var isSet: Bool {
            unsafe withUnsafeMutablePointer(to: &_value) { ptr in
                unsafe (CPU.Atomic.load(ptr, ordering: .acquiring) != 0)
            }
        }

        /// Sets the flag to `true`.
        ///
        /// Uses releasing memory ordering to ensure all prior writes
        /// are visible to threads that observe `isSet == true`.
        ///
        /// This operation is idempotent - calling it multiple times
        /// has the same effect as calling it once.

        public func set() {
            unsafe withUnsafeMutablePointer(to: &_value) { ptr in
                unsafe CPU.Atomic.store(ptr, 1, ordering: .releasing)
            }
        }
    }
}
