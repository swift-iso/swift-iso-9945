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

// MARK: - Lock Token

extension ISO_9945.Kernel.Lock {
    /// A move-only token representing a held file lock.
    ///
    /// `Token` ensures the lock is released when it goes out of scope.
    /// It is `~Copyable` to prevent accidental duplication of lock ownership.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let token = try POSIX.Kernel.Lock.Token(
    ///     descriptor: fd,
    ///     range: .file,
    ///     kind: .exclusive
    /// )
    /// defer { token.release() }
    ///
    /// // ... use the locked file ...
    /// ```
    ///
    /// ## Lifetime
    ///
    /// - `release()` is the canonical way to release the lock
    /// - `deinit` releases the lock as a backstop (correctness should not depend on this)
    /// - Once released, the token cannot be used
    ///
    /// ## Thread Safety
    ///
    /// Token stores a `Kernel.Descriptor` which is conditionally `Sendable`.
    /// The mutable `isReleased` state is safe because `~Copyable` ensures
    /// single ownership - only one thread can own the token at a time.
    public struct Token: ~Copyable, Sendable {
        private let descriptor: Kernel.Descriptor
        private let range: Kernel.Lock.Range
        private var isReleased: Bool

        /// Creates a lock token by acquiring a lock.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor.
        ///   - range: The byte range to lock.
        ///   - kind: The lock kind (shared or exclusive).
        ///   - acquire: The acquisition strategy (default: `.wait`).
        /// - Throws: `Kernel.Lock.Error` if locking fails.
        public init(
            descriptor: Kernel.Descriptor,
            range: Kernel.Lock.Range = .file,
            kind: Kernel.Lock.Kind,
            acquire: Kernel.Lock.Acquire = .wait
        ) throws(Kernel.Lock.Error) {
            self.descriptor = descriptor
            self.range = range
            self.isReleased = false

            try Self.acquireLock(
                descriptor: descriptor,
                range: range,
                kind: kind,
                acquire: acquire
            )
        }

        /// Releases the lock.
        ///
        /// On success, the token is marked released and subsequent calls are no-ops.
        /// On failure, the token remains valid for retry - the lock is preserved.
        ///
        /// - Throws: `Kernel.Lock.Error` if the unlock syscall fails.
        public mutating func release() throws(Kernel.Lock.Error) {
            guard !isReleased else { return }
            try ISO_9945.Kernel.Lock.unlock(descriptor, range: range)
            isReleased = true
        }

        deinit {
            // Backstop release - correctness should not depend on this
            guard !isReleased else { return }
            _ = Result { try ISO_9945.Kernel.Lock.unlock(descriptor, range: range) }
        }
    }
}

// MARK: - Token Acquisition Logic

extension ISO_9945.Kernel.Lock.Token {
    /// Acquires a lock using the specified strategy.
    private static func acquireLock(
        descriptor: Kernel.Descriptor,
        range: Kernel.Lock.Range,
        kind: Kernel.Lock.Kind,
        acquire: Kernel.Lock.Acquire
    ) throws(Kernel.Lock.Error) {
        switch acquire {
        case .try:
            try ISO_9945.Kernel.Lock.Immediate.lock(descriptor, range: range, kind: kind)

        case .wait:
            try ISO_9945.Kernel.Lock.lock(descriptor, range: range, kind: kind)

        case .deadline(let deadline):
            try acquireWithDeadline(
                descriptor: descriptor,
                range: range,
                kind: kind,
                deadline: deadline
            )
        }
    }

    /// Polls for a lock until the deadline expires.
    ///
    /// Uses exponential backoff starting at 1ms, capped at 100ms.
    private static func acquireWithDeadline(
        descriptor: Kernel.Descriptor,
        range: Kernel.Lock.Range,
        kind: Kernel.Lock.Kind,
        deadline: Clock.Continuous.Instant
    ) throws(Kernel.Lock.Error) {
        var backoff: Duration = .milliseconds(1)
        let maxBackoff: Duration = .milliseconds(100)

        while true {
            // Check deadline first
            let now = Clock.Continuous.now
            if now >= deadline {
                throw .contention
            }

            // Try to acquire
            do throws(Kernel.Lock.Error) {
                try ISO_9945.Kernel.Lock.Immediate.lock(descriptor, range: range, kind: kind)
                // Critical: re-check deadline after acquisition
                // If deadline passed, unlock and throw to maintain invariant:
                // "success means lock was acquired before deadline"
                if Clock.Continuous.now >= deadline {
                    try? ISO_9945.Kernel.Lock.unlock(descriptor, range: range)
                    throw Kernel.Lock.Error.contention
                }
                return
            } catch {
                switch error {
                case .contention:
                    break  // Lock held, continue polling
                case .deadlock, .unavailable:
                    throw error
                }
            }

            // Calculate sleep time (don't overshoot deadline)
            let remaining = deadline - Clock.Continuous.now
            if remaining <= .zero {
                throw .contention
            }

            let sleepDuration = min(backoff, remaining)
            sleep(sleepDuration)

            // Exponential backoff with cap
            backoff = min(backoff * 2, maxBackoff)
        }
    }

    /// Platform-specific sleep without Foundation dependency.
    private static func sleep(_ duration: Duration) {
        let (seconds, attoseconds) = duration.components
        let nanoseconds = UInt64(seconds) * 1_000_000_000 + UInt64(attoseconds) / 1_000_000_000

        var ts = timespec()
        ts.tv_sec = Int(nanoseconds / 1_000_000_000)
        ts.tv_nsec = Int(nanoseconds % 1_000_000_000)
        nanosleep(&ts, nil)
    }
}

// MARK: - Scoped Locking Helpers

extension ISO_9945.Kernel.Lock {
    /// Error thrown by scoped locking helpers.
    public enum WithLockError<E: Swift.Error & Sendable>: Swift.Error, Sendable {
        /// Lock acquisition or release failed.
        case lock(Kernel.Lock.Error)
        /// The body closure threw an error.
        case body(E)
    }

    /// Executes a closure while holding an exclusive lock.
    ///
    /// The lock is automatically released when the closure completes.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - range: The byte range to lock (default: whole file).
    ///   - acquire: The acquisition strategy (default: `.wait`).
    ///   - body: The closure to execute while holding the lock.
    /// - Returns: The result of the closure.
    /// - Throws: `WithLockError` if locking fails or the closure throws.
    public static func withExclusive<T, E: Swift.Error & Sendable>(
        _ descriptor: Kernel.Descriptor,
        range: Kernel.Lock.Range = .file,
        acquire: Kernel.Lock.Acquire = .wait,
        _ body: () throws(E) -> T
    ) throws(WithLockError<E>) -> T {
        var token: Token
        do {
            token = try Token(descriptor: descriptor, range: range, kind: .exclusive, acquire: acquire)
        } catch {
            throw .lock(error)
        }
        defer { try? token.release() }
        do {
            return try body()
        } catch {
            throw .body(error)
        }
    }

    /// Executes a closure while holding a shared lock.
    ///
    /// The lock is automatically released when the closure completes.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - range: The byte range to lock (default: whole file).
    ///   - acquire: The acquisition strategy (default: `.wait`).
    ///   - body: The closure to execute while holding the lock.
    /// - Returns: The result of the closure.
    /// - Throws: `WithLockError` if locking fails or the closure throws.
    public static func withShared<T, E: Swift.Error & Sendable>(
        _ descriptor: Kernel.Descriptor,
        range: Kernel.Lock.Range = .file,
        acquire: Kernel.Lock.Acquire = .wait,
        _ body: () throws(E) -> T
    ) throws(WithLockError<E>) -> T {
        var token: Token
        do {
            token = try Token(descriptor: descriptor, range: range, kind: .shared, acquire: acquire)
        } catch {
            throw .lock(error)
        }
        defer { try? token.release() }
        do {
            return try body()
        } catch {
            throw .body(error)
        }
    }
}
