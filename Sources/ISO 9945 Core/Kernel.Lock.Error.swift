// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
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
    }
}

extension ISO_9945.Kernel.Lock.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .contention: return "lock contention"
        case .deadlock: return "deadlock detected"
        case .unavailable: return "no locks available"
        }
    }
}

extension ISO_9945.Kernel.Lock.Error {
    /// Lock acquisition timed out.
    ///
    /// Thrown when `.deadline(...)` acquisition cannot acquire the lock
    /// before the deadline expires.
    public static let timedOut = Self.contention  // Reuse contention semantically

    /// Lock would block (for `.try` acquisition).
    public static let wouldBlock = Self.contention
}

// MARK: - Platform Bindings
//
// Per [PLAT-ARCH-008c], the platform-specific `init?(code:)` mapping lives in L2:
// - POSIX: `swift-iso-9945` (`ISO 9945.Kernel.Lock.Error+code.swift`)
// - Windows: `swift-windows-standard` (`Windows.Kernel.Lock.Error+code.swift`)

