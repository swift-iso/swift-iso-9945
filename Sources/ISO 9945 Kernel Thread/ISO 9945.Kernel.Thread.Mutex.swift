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

// MARK: - POSIX Thread Mutex

extension ISO_9945.Kernel.Thread {
    /// A low-level mutex for thread synchronization.
    ///
    /// This is a policy-free wrapper around `pthread_mutex_t`.
    ///
    /// ## Threading
    /// - **lock()**: Blocks the calling thread until the mutex is available
    /// - **lock.immediate()**: Returns immediately, throws on contention
    /// - **unlock()**: Must be called from the thread that acquired the lock
    ///
    /// ## Cancellation
    /// Mutex operations are not cancellation points. A thread blocked on `lock()`
    /// cannot be cancelled until it acquires the mutex.
    ///
    /// ## Scheduling
    /// No fairness guarantees. Under contention, lock acquisition order is
    /// platform-dependent and may not be FIFO.
    ///
    /// ## Safety
    /// This type is `@unchecked Sendable` because it provides internal synchronization.
    /// The mutex itself is what makes cross-thread access safe.
    ///
    /// ## Usage
    /// ```swift
    /// let mutex = ISO_9945.Kernel.Thread.Mutex()
    /// mutex.lock()
    /// defer { mutex.unlock() }
    /// // ... critical section ...
    /// ```
    ///
    /// For scoped locking, use `withLock`:
    /// ```swift
    /// let result = mutex.withLock {
    ///     // ... critical section ...
    ///     return someValue
    /// }
    /// ```
    ///
    /// For non-blocking lock attempts:
    /// ```swift
    /// do {
    ///     try mutex.lock.immediate()
    ///     defer { mutex.unlock() }
    ///     // ... critical section ...
    /// } catch {
    ///     // Mutex held by another thread
    /// }
    /// ```
    public final class Mutex: @unchecked Sendable {
        private var mutex: pthread_mutex_t

        /// Creates a new mutex.
        ///
        /// - Note: `pthread_mutex_init` can only fail here with `ENOMEM` or
        ///   `EAGAIN` (default attributes are always valid), both of which
        ///   mean the process cannot create any more synchronization
        ///   primitives. There is no useful recovery at a non-throwing,
        ///   value-type initializer used pervasively as `Mutex()` (including
        ///   from non-throwing thread-body closures), so failure is reported
        ///   loudly via `precondition` rather than silently leaving
        ///   every subsequent lock operation running against an
        ///   uninitialized mutex.
        public init() {
            self.mutex = pthread_mutex_t()
            var attr = pthread_mutexattr_t()
            unsafe pthread_mutexattr_init(&attr)
            let result = unsafe pthread_mutex_init(&self.mutex, &attr)
            unsafe pthread_mutexattr_destroy(&attr)
            precondition(result == 0, "pthread_mutex_init failed with code \(result)")
        }

        deinit {
            unsafe pthread_mutex_destroy(&mutex)
        }
    }
}

// MARK: - Lock Operations

extension ISO_9945.Kernel.Thread.Mutex {
    /// Releases the mutex, allowing other threads to acquire it.
    ///
    /// ## Precondition
    /// The mutex **must** be held by the current thread. Calling `unlock()` on
    /// a mutex not held by the current thread is **undefined behavior**:
    /// - May silently corrupt internal state
    /// - May cause other threads to deadlock or crash
    /// - Behavior is platform-specific and unpredictable
    ///
    /// - Note: `pthread_mutex_unlock` failure (`EPERM`, `EINVAL`) means the
    ///   precondition above was already violated by the caller. This is a
    ///   non-throwing entry point — including from non-throwing thread-body
    ///   closures via `ISO_9945.Kernel.Thread.create` — so the failure is
    ///   reported via `precondition` rather than silently discarded.
    public func unlock() {
        let result = unsafe pthread_mutex_unlock(&mutex)
        precondition(result == 0, "pthread_mutex_unlock failed with code \(result)")
    }

    /// Accessor for lock operation variants.
    ///
    /// - `mutex.lock()` - blocking, waits until available
    /// - `try mutex.lock.immediate()` - non-blocking, throws on contention
    public var lock: Lock { Lock(mutex: self) }
}

// MARK: - Scoped Locking

extension ISO_9945.Kernel.Thread.Mutex {
    /// Internal blocking lock implementation.
    ///
    /// - Note: `pthread_mutex_lock` on a default (non-error-checking) mutex
    ///   only fails with `EINVAL` (uninitialized/destroyed mutex) or
    ///   `EDEADLK` on platforms whose default type happens to detect
    ///   self-deadlock. Both are programmer-error invariant violations, not
    ///   recoverable runtime conditions, and this is a non-throwing entry
    ///   point reachable from non-throwing thread-body closures, so the
    ///   failure is reported via `precondition` rather than silently
    ///   discarded.
    func acquireBlocking() {
        let result = unsafe pthread_mutex_lock(&mutex)
        precondition(result == 0, "pthread_mutex_lock failed with code \(result)")
    }

    /// Internal non-blocking lock attempt.
    ///
    /// - Returns: The raw `pthread_mutex_trylock` result: `0` on success,
    ///   `EBUSY` if another thread holds the lock, or another errno value
    ///   (e.g. `EINVAL`, `EAGAIN`) for a genuine misuse the caller did not
    ///   verify — kept distinct from contention by `Lock.immediate()`.
    func tryAcquire() -> Int32 {
        unsafe pthread_mutex_trylock(&mutex)
    }

    /// Executes a closure while holding the mutex.
    ///
    /// The mutex is automatically acquired before and released after the closure.
    ///
    /// - Parameter body: The closure to execute while holding the mutex.
    /// - Returns: The value returned by the closure.
    /// - Throws: Any error thrown by `body`.
    public func withLock<T, E: Swift.Error>(_ body: () throws(E) -> T) throws(E) -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}

// MARK: - Internal Access for Condition

extension ISO_9945.Kernel.Thread.Mutex {
    /// Provides access to the underlying platform mutex pointer.
    ///
    /// This is internal API for `Condition` to use when waiting.
    /// - Parameter body: A closure that receives the pointer.
    /// - Returns: The value returned by `body`.
    func withUnsafeMutablePointer<T>(_ body: (UnsafeMutablePointer<pthread_mutex_t>) -> T) -> T {
        unsafe Swift.withUnsafeMutablePointer(to: &mutex, body)
    }
}
