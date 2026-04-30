// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-posix open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-posix project authors
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

extension ISO_9945.Kernel.Signal {
    /// Signal mask operations namespace.
    ///
    /// ## Threading
    ///
    /// Signal masks are per-thread. `Mask.change` uses `pthread_sigmask`
    /// which is thread-safe and affects only the calling thread.
    ///
    /// ## Blocking Behavior
    ///
    /// Operations are synchronous and non-blocking.
    public enum Mask {}
}

extension ISO_9945.Kernel.Signal.Mask {
    /// Changes the signal mask for the calling thread.
    ///
    /// - Parameters:
    ///   - how: How to modify the mask (block, unblock, or replace).
    ///   - signals: The signals to block, unblock, or set as the new mask.
    /// - Returns: The previous signal mask.
    /// - Throws: `Error.mask` on failure.
    ///
    /// ## Implementation
    ///
    /// Uses `pthread_sigmask` (thread-safe), not `sigprocmask`.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Block SIGINT and SIGTERM
    /// var toBlock = ISO_9945.Kernel.Signal.Set()
    /// try toBlock.insert(.interrupt)
    /// try toBlock.insert(.terminate)
    ///
    /// let previous = try ISO_9945.Kernel.Signal.Mask.change(.block, signals: toBlock)
    /// defer { _ = try? ISO_9945.Kernel.Signal.Mask.change(.set, signals: previous) }
    ///
    /// // Critical section where signals are blocked
    /// ```

    public static func change(
        _ how: How,
        signals: ISO_9945.Kernel.Signal.Set
    ) throws(ISO_9945.Kernel.Signal.Error) -> ISO_9945.Kernel.Signal.Set {
        var previous = sigset_t()
        unsafe sigemptyset(&previous)

        // pthread_sigmask returns error number directly, not via errno
        let error = unsafe signals.withUnsafePointer { setPtr in
            unsafe pthread_sigmask(how.rawValue, setPtr, &previous)
        }

        guard error == 0 else {
            throw .mask(.posix(error))
        }

        return ISO_9945.Kernel.Signal.Set(storage: previous)
    }

    /// Returns the set of pending signals (blocked but raised).
    ///
    /// A signal is pending if it has been raised but is currently blocked
    /// by the thread's signal mask.
    ///
    /// - Returns: The set of pending signals.
    /// - Throws: `Error.mask` on failure.
    ///
    /// ## Implementation
    ///
    /// Uses `sigpending`.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Check if any signals are pending
    /// let pending = try ISO_9945.Kernel.Signal.Mask.pending()
    /// if try pending.contains(.interrupt) {
    ///     // SIGINT was raised while blocked
    /// }
    /// ```

    public static func pending() throws(ISO_9945.Kernel.Signal.Error) -> ISO_9945.Kernel.Signal.Set {
        var set = sigset_t()
        unsafe sigemptyset(&set)

        guard unsafe sigpending(&set) == 0 else {
            throw .mask(Error_Primitives.Error.captureErrno())
        }

        return ISO_9945.Kernel.Signal.Set(storage: set)
    }
}
