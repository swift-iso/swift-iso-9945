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
    /// let token = try ISO_9945.Kernel.Lock.Token(
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
    /// Token stores a `ISO_9945.Kernel.Descriptor` which is conditionally `Sendable`.
    /// The mutable `isReleased` state is safe because `~Copyable` ensures
    /// single ownership - only one thread can own the token at a time.
    public struct Token: ~Copyable, Sendable {
        /// The descriptor whose lock this token represents.
        ///
        /// Token takes ownership via `consuming` in `init`. The caller
        /// transfers the descriptor to Token when acquiring a lock, and
        /// Token owns it until the token is destroyed — at which point
        /// the descriptor's own `deinit` closes the fd.
        ///
        /// This prevents the double-close that would occur if Token
        /// stored a new `ISO_9945.Kernel.Descriptor` constructed from the caller's
        /// raw value (both the caller's and Token's descriptors would
        /// call `close()` on the same fd).
        @usableFromInline internal let descriptor: ISO_9945.Kernel.Descriptor
        @usableFromInline internal let range: ISO_9945.Kernel.Lock.Range
        @usableFromInline internal var isReleased: Bool

        /// Creates a lock token by acquiring a lock.
        ///
        /// Token takes ownership of `descriptor`. When the token is
        /// destroyed (explicitly via `release()` followed by scope exit,
        /// or implicitly via scope exit without an explicit release),
        /// the descriptor's `deinit` closes the fd.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor. Ownership is transferred to the Token.
        ///   - range: The byte range to lock.
        ///   - kind: The lock kind (shared or exclusive).
        ///   - acquire: The acquisition strategy (default: `.wait`).
        /// - Throws: `ISO_9945.Kernel.Lock.Error` if locking fails. On throw, the
        ///   consumed descriptor is destroyed by init cleanup (its deinit
        ///   closes the fd).
        public init(
            descriptor: consuming ISO_9945.Kernel.Descriptor,
            range: ISO_9945.Kernel.Lock.Range = .file,
            kind: ISO_9945.Kernel.Lock.Kind,
            acquire: ISO_9945.Kernel.Lock.Acquire = .wait
        ) throws(ISO_9945.Kernel.Lock.Error) {
            // Acquire the lock first, borrowing the consuming parameter
            // without moving it. If acquireLock throws, the consuming
            // parameter is destroyed on init cleanup.
            try Self.acquireLock(
                descriptor: descriptor,
                range: range,
                kind: kind,
                acquire: acquire
            )
            // Successful acquisition — transfer ownership into Token.
            self.descriptor = descriptor
            self.range = range
            self.isReleased = false
        }

        /// Releases the lock.
        ///
        /// On success, the token is marked released and subsequent calls
        /// are no-ops. On failure, the token remains valid for retry —
        /// the lock is preserved.
        ///
        /// The Token retains ownership of the descriptor after release;
        /// the fd is closed when the Token goes out of scope.
        ///
        /// - Throws: `ISO_9945.Kernel.Lock.Error` if the unlock syscall fails.
        public mutating func release() throws(ISO_9945.Kernel.Lock.Error) {
            guard !isReleased else { return }
            try ISO_9945.Kernel.Lock.unlock(descriptor, range: range)
            isReleased = true
        }

        deinit {
            // Backstop release: if the token was dropped without calling
            // release(), unlock via the owned descriptor. The descriptor's
            // own deinit runs immediately after and closes the fd.
            guard !isReleased else { return }
            try? ISO_9945.Kernel.Lock.unlock(descriptor, range: range)
        }
    }
}

// MARK: - Token Acquisition Logic

extension ISO_9945.Kernel.Lock.Token {
    /// Acquires a lock using the specified strategy.
    private static func acquireLock(
        descriptor: borrowing ISO_9945.Kernel.Descriptor,
        range: ISO_9945.Kernel.Lock.Range,
        kind: ISO_9945.Kernel.Lock.Kind,
        acquire: ISO_9945.Kernel.Lock.Acquire
    ) throws(ISO_9945.Kernel.Lock.Error) {
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
        descriptor: borrowing ISO_9945.Kernel.Descriptor,
        range: ISO_9945.Kernel.Lock.Range,
        kind: ISO_9945.Kernel.Lock.Kind,
        deadline: Clock.Continuous.Instant
    ) throws(ISO_9945.Kernel.Lock.Error) {
        var backoff: Duration = .milliseconds(1)
        let maxBackoff: Duration = .milliseconds(100)

        while true {
            // Check deadline first
            let now = Clock.Continuous.now
            if now >= deadline {
                throw .contention
            }

            // Try to acquire
            do throws(ISO_9945.Kernel.Lock.Error) {
                try ISO_9945.Kernel.Lock.Immediate.lock(descriptor, range: range, kind: kind)
                // Critical: re-check deadline after acquisition
                // If deadline passed, unlock and throw to maintain invariant:
                // "success means lock was acquired before deadline"
                if Clock.Continuous.now >= deadline {
                    try? ISO_9945.Kernel.Lock.unlock(descriptor, range: range)
                    throw ISO_9945.Kernel.Lock.Error.contention
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
        unsafe nanosleep(&ts, nil)
    }
}

// MARK: - Scoped Locking Helpers

extension ISO_9945.Kernel.Lock {
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
    /// - Throws: `ISO_9945.Kernel.Lock.Scope.Error` if locking fails or the closure throws.
    public static func withExclusive<T, E: Swift.Error>(
        _ descriptor: consuming ISO_9945.Kernel.Descriptor,
        range: ISO_9945.Kernel.Lock.Range = .file,
        acquire: ISO_9945.Kernel.Lock.Acquire = .wait,
        _ body: () throws(E) -> T
    ) throws(ISO_9945.Kernel.Lock.Scope.Error<E>) -> T {
        var token: Token
        do {
            token = try Token(
                descriptor: consume descriptor,
                range: range,
                kind: .exclusive,
                acquire: acquire
            )
        } catch {
            throw .lock(error)
        }
        // Token owns the descriptor. On scope exit, the token is destroyed
        // and the descriptor's deinit closes the fd exactly once.
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
    /// - Throws: `ISO_9945.Kernel.Lock.Scope.Error` if locking fails or the closure throws.
    public static func withShared<T, E: Swift.Error>(
        _ descriptor: consuming ISO_9945.Kernel.Descriptor,
        range: ISO_9945.Kernel.Lock.Range = .file,
        acquire: ISO_9945.Kernel.Lock.Acquire = .wait,
        _ body: () throws(E) -> T
    ) throws(ISO_9945.Kernel.Lock.Scope.Error<E>) -> T {
        var token: Token
        do {
            token = try Token(
                descriptor: consume descriptor,
                range: range,
                kind: .shared,
                acquire: acquire
            )
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
