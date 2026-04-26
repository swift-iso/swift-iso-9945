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

// MARK: - POSIX Thread Local Storage Key

extension ISO_9945.Kernel.Thread {
    /// Per-thread storage key — a policy-free wrapper around the POSIX
    /// `pthread_key_t` family (`pthread_key_create`, `pthread_setspecific`,
    /// `pthread_getspecific`, `pthread_key_delete`).
    ///
    /// Spec-mirrors POSIX `pthread_key_t` per [API-NAME-003]. The L3
    /// unifier ``Kernel/Thread/Local`` wraps this raw key with typed
    /// payload accessors and the `Unmanaged` retain/release dance —
    /// per [PLAT-ARCH-008f] solution (a), the L2 raw type uses the
    /// spec-literal name to free `Local` for the L3 typed wrapper.
    ///
    /// Each `Key` instance owns one platform-allocated TLS key. The
    /// key is freed on `deinit`. The slot stores an
    /// `UnsafeMutableRawPointer?` per thread; consumers cast to/from
    /// their typed payload at the boundary (or use the L3 generic
    /// `Kernel.Thread.Local<Payload>` which encapsulates the cast).
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
    /// let key = ISO_9945.Kernel.Thread.Key()
    /// key.value = UnsafeMutableRawPointer(...)
    /// // ... synchronous code on the same thread reads `key.value` ...
    /// ```
    public final class Key: @unchecked Sendable {
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
