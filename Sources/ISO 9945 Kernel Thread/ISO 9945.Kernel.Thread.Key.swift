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
    /// `ISO_9945.Kernel.Thread.Local<Payload>` which encapsulates the cast).
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

        /// Allocates a new TLS key with no per-thread destructor.
        ///
        /// The slot value is not automatically released on thread exit —
        /// callers must clear the slot before threads exit, or accept
        /// the leak. For automatic per-thread cleanup, use
        /// ``init(destructor:)``.
        public init() {
            self.key = pthread_key_t()
            unsafe pthread_key_create(&self.key, nil)
        }

        /// Allocates a new TLS key with a per-thread destructor.
        ///
        /// `destructor` is invoked by the kernel on thread exit IF the
        /// thread's slot value is non-`nil` at exit. The kernel passes
        /// the slot value to the destructor, then sets the slot to
        /// `nil`. Use this to release retained payloads automatically
        /// (see the L3 ``Kernel/Thread/Local`` typed wrapper).
        ///
        /// Per POSIX, if the destructor sets a new value on the same
        /// key, the kernel may invoke the destructor again, up to
        /// `PTHREAD_DESTRUCTOR_ITERATIONS` times — typically 4. A
        /// destructor that only releases (and does not re-set) avoids
        /// re-entry.
        public init(destructor: @convention(c) (UnsafeMutableRawPointer) -> Void) {
            self.key = pthread_key_t()
            #if canImport(Darwin)
                unsafe pthread_key_create(&self.key, destructor)
            #else
                // Linux/Musl glibc imports pthread_key_create's destructor as
                // `(UnsafeMutableRawPointer?) -> Void` (Optional input), while
                // Darwin imports it as non-Optional. The C ABI is identical; only
                // the Swift importer's nullability decision differs. unsafeBitCast
                // converts between the Swift representations without changing the
                // bits. The kernel only invokes the destructor with non-nil values
                // per POSIX semantics (the slot value is non-nil at thread exit),
                // so the (NonOpt) closure is correctly invoked at runtime.
                let optDestructor = unsafe unsafeBitCast(
                    destructor,
                    to: (@convention(c) (UnsafeMutableRawPointer?) -> Void).self
                )
                unsafe pthread_key_create(&self.key, optDestructor)
            #endif
        }

        deinit {
            pthread_key_delete(key)
        }
    }
}

extension ISO_9945.Kernel.Thread.Key {
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
