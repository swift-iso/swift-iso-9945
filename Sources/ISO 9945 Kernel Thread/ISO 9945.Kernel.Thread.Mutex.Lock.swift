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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Lock Accessor

extension ISO_9945.Kernel.Thread.Mutex {
    /// Lock operation accessor with variants.
    public struct Lock: Sendable {
        let mutex: ISO_9945.Kernel.Thread.Mutex
    }
}

// MARK: - Error

extension ISO_9945.Kernel.Thread.Mutex.Lock {
    /// Error thrown when a non-blocking lock cannot be acquired.
    public enum Error: Swift.Error, Sendable {
        /// The mutex is held by another thread (`EBUSY`).
        case contention

        /// `pthread_mutex_trylock` failed for a reason other than
        /// contention (e.g. `EINVAL` uninitialized mutex, `EAGAIN`
        /// recursion limit) — a misuse the caller did not verify, not
        /// "held by another thread".
        case platform(Error_Primitives.Error.Code)
    }
}

// MARK: - Lock Operations

extension ISO_9945.Kernel.Thread.Mutex.Lock {
    /// Acquires the mutex, blocking until available.
    ///
    /// ## Threading
    /// Blocks the calling thread until the mutex becomes available.
    ///
    /// ## Deadlock
    /// Calling `lock()` on a mutex already held by the current thread causes
    /// **deadlock**. Use `lock.immediate()` to check ownership without blocking.
    public func callAsFunction() {
        mutex.acquireBlocking()
    }

    /// Attempts to acquire the mutex without blocking.
    ///
    /// ## Threading
    /// Never blocks. Returns immediately regardless of mutex state.
    ///
    /// - Throws: `Error.contention` if the mutex is held by another thread,
    ///   or `Error.platform` if `pthread_mutex_trylock` failed for any
    ///   other reason.
    public func immediate() throws(Error) {
        let result = mutex.tryAcquire()
        guard result != 0 else { return }
        guard result == EBUSY else {
            throw .platform(.posix(result))
        }
        throw .contention
    }
}
