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
        public init() {
            self.mutex = pthread_mutex_t()
            var attr = pthread_mutexattr_t()
            unsafe pthread_mutexattr_init(&attr)
            unsafe pthread_mutex_init(&self.mutex, &attr)
            unsafe pthread_mutexattr_destroy(&attr)
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
    public func unlock() {
        unsafe pthread_mutex_unlock(&mutex)
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
    func acquireBlocking() {
        unsafe pthread_mutex_lock(&mutex)
    }

    /// Internal non-blocking lock attempt.
    ///
    /// - Returns: `true` if the lock was acquired, `false` on contention.
    func tryAcquire() -> Bool {
        unsafe pthread_mutex_trylock(&mutex) == 0
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
