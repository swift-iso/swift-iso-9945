// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.Lock {
    /// Lock operation errors.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Lock contention - another process holds a conflicting lock.
        /// - POSIX: `EAGAIN` on `F_SETLK` (non-blocking)
        /// - Windows: `ERROR_LOCK_VIOLATION`
        ///
        /// This is only thrown when `wait: false`. Use `try?` pattern:
        /// ```swift
        /// if (try? ISO_9945.Kernel.Lock.lock(fd, range: .file, exclusive: true, wait: false)) != nil {
        ///     // Lock acquired
        /// }
        /// ```
        case contention

        /// Deadlock detected.
        /// - POSIX: `EDEADLK`
        ///
        /// The kernel detected that acquiring this lock would cause
        /// a deadlock with another process.
        case deadlock

        /// No locks available - system lock table exhausted.
        /// - POSIX: `ENOLCK`
        ///
        /// This is resource exhaustion, not contention.
        case unavailable

        /// Lock acquisition timed out.
        ///
        /// Thrown when `.deadline(...)` acquisition cannot acquire the lock
        /// before the deadline expires. Distinct from ``contention``: the
        /// lock may or may not still be held when the deadline expires.
        case timedOut

        /// The blocking lock wait was interrupted by a signal.
        /// - POSIX: `EINTR` on `F_SETLKW`
        ///
        /// The lock was not acquired; the caller may retry.
        case interrupted

        /// The requested byte range is invalid (end precedes start).
        case invalidRange(start: Int64, end: Int64)

        /// A platform error the lock vocabulary does not classify.
        ///
        /// Carries the platform code so a misuse errno (`EBADF`, `EINVAL`,
        /// `EOVERFLOW`, …) stays distinguishable from contention.
        case platform(code: Error_Primitives.Error.Code)
    }
}

extension ISO_9945.Kernel.Lock.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .contention: return "lock contention"
        case .deadlock: return "deadlock detected"
        case .unavailable: return "no locks available"
        case .timedOut: return "lock acquisition timed out"
        case .interrupted: return "lock wait interrupted by a signal"
        case .invalidRange(let start, let end): return "invalid lock range: start \(start), end \(end)"
        case .platform(let code): return "platform error \(code)"
        }
    }
}

// MARK: - Platform Bindings
//
// Per [PLAT-ARCH-008c], the platform-specific `init?(code:)` mapping lives in L2:
// - POSIX: `swift-iso-9945` (`ISO 9945.Kernel.Lock.Error+code.swift`)
// - Windows: `swift-windows-standard` (`Windows.Kernel.Lock.Error+code.swift`)
