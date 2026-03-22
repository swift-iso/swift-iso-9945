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

// MARK: - POSIX Thread Handle

extension ISO_9945.Kernel.Thread {
    /// Opaque handle to a POSIX thread.
    ///
    /// ## Move-Only Semantics
    /// This type is `~Copyable` to enforce exactly-once `join()` semantics.
    /// Copying the handle would allow double-join, which is undefined behavior
    /// (double `pthread_join`).
    ///
    /// ## Safety
    /// This type is `@unchecked Sendable` because the underlying `pthread_t`
    /// can be safely passed between threads.
    /// The move-only constraint ensures exactly-once consumption.
    @safe
    public struct Handle: ~Copyable, @unchecked Sendable {
        internal let rawValue: pthread_t

        /// Creates a handle from a pthread_t.
        internal init(rawValue: pthread_t) {
            unsafe (self.rawValue = rawValue)
        }
    }
}

// MARK: - Handle Operations

extension ISO_9945.Kernel.Thread.Handle {
    /// Waits for the thread to complete and releases the handle.
    ///
    /// This is a consuming operation - the handle cannot be used after calling `join()`.
    /// Calls `pthread_join`.
    ///
    /// - Precondition: Must NOT be called from the same thread (deadlock).
    /// - Note: Must be called exactly once. The `~Copyable` constraint enforces this.

    public consuming func join() {
        _ = unsafe pthread_join(rawValue, nil)
    }

    /// Detaches the thread, allowing it to run independently.
    ///
    /// After detaching, resources are automatically cleaned up when the thread exits.
    /// This is a consuming operation - the handle cannot be used after calling `detach()`.
    /// Calls `pthread_detach`.

    public consuming func detach() {
        _ = unsafe pthread_detach(rawValue)
    }

    /// Check if this handle refers to the current thread.
    ///
    /// Used for shutdown safety to prevent join-on-self deadlock.

    public var isCurrent: Bool {
        unsafe (pthread_equal(pthread_self(), rawValue) != 0)
    }
}
