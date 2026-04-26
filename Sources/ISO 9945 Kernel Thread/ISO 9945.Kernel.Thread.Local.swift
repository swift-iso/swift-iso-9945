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

// MARK: - POSIX Thread Local Storage

extension ISO_9945.Kernel.Thread {
    /// Per-thread storage slot — a policy-free wrapper around the POSIX
    /// `pthread_key_t` family (`pthread_key_create`, `pthread_setspecific`,
    /// `pthread_getspecific`, `pthread_key_delete`).
    ///
    /// Each `Local` instance owns one platform-allocated TLS key. The
    /// key is freed on `deinit`. The slot stores an
    /// `UnsafeMutableRawPointer?` per thread; consumers cast to/from
    /// their typed payload at the boundary.
    ///
    /// ## Threading
    /// - **value (get)**: Returns the calling thread's slot value, or
    ///   `nil` if the thread has not set one (or has not allocated).
    /// - **value (set)**: Sets the calling thread's slot value.
    ///
    /// ## Safety
    /// `@unchecked Sendable` because pthread_setspecific/getspecific are
    /// per-thread by construction — the kernel provides the per-thread
    /// isolation. The class itself is just a handle to the platform's
    /// TLS-key registry.
    ///
    /// ## Public API surface
    /// Per [PLAT-ARCH-005a], no platform C types appear in the public
    /// API: `pthread_key_t` is internal storage; the slot type is
    /// `UnsafeMutableRawPointer?` (stdlib).
    ///
    /// ## Usage
    /// ```swift
    /// let local = ISO_9945.Kernel.Thread.Local()
    /// local.value = UnsafeMutableRawPointer(...)
    /// // ... synchronous code on the same thread reads `local.value` ...
    /// ```
    public final class Local: @unchecked Sendable {
        private var key: pthread_key_t

        /// Allocates a new TLS key.
        public init() {
            self.key = pthread_key_t()
            unsafe pthread_key_create(&self.key, nil)
        }

        deinit {
            unsafe pthread_key_delete(key)
        }

        /// The calling thread's slot value. `nil` if the thread has not
        /// set a value, or if the slot was just allocated.
        public var value: UnsafeMutableRawPointer? {
            get {
                unsafe pthread_getspecific(key)
            }
            set {
                unsafe (_ = pthread_setspecific(key, newValue))
            }
        }
    }
}
