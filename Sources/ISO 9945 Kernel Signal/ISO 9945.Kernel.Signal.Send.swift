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
    /// Signal sending operations.
    ///
    /// ## Threading
    ///
    /// All operations are thread-safe (kernel provides synchronization).
    ///
    /// ## Blocking Behavior
    ///
    /// Operations are synchronous and non-blocking.
    public enum Send {}
}

extension ISO_9945.Kernel.Signal.Send {
    /// Sends a signal to a process.
    ///
    /// - Parameters:
    ///   - signal: The signal to send.
    ///   - pid: The target process ID.
    /// - Throws: `ISO_9945.Kernel.Signal.Error.send` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.noPermission` (EPERM): Caller lacks permission to send signal to target.
    /// - `.noSuchProcess` (ESRCH): No process with the specified PID exists.
    /// - `.invalidSignal` (EINVAL): Invalid signal number.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Send SIGTERM to a process
    /// try ISO_9945.Kernel.Signal.Send.toProcess(.terminate, pid: targetPid)
    /// ```

    public static func toProcess(
        _ signal: ISO_9945.Kernel.Signal.Number,
        pid: ISO_9945.Kernel.Process.ID
    ) throws(ISO_9945.Kernel.Signal.Error) {
        guard kill(pid.rawValue, signal.rawValue) == 0 else {
            throw .send(Error_Primitives.Error.captureErrno())
        }
    }

    /// Sends a signal to the calling process.
    ///
    /// - Parameter signal: The signal to send.
    /// - Throws: `ISO_9945.Kernel.Signal.Error.send` on failure.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Send SIGUSR1 to self
    /// try ISO_9945.Kernel.Signal.Send.toSelf(.user1)
    /// ```

    public static func toSelf(
        _ signal: ISO_9945.Kernel.Signal.Number
    ) throws(ISO_9945.Kernel.Signal.Error) {
        guard raise(signal.rawValue) == 0 else {
            throw .send(Error_Primitives.Error.captureErrno())
        }
    }

    /// Sends a signal to a process group.
    ///
    /// - Parameters:
    ///   - signal: The signal to send.
    ///   - pgid: The target process group ID.
    /// - Throws: `ISO_9945.Kernel.Signal.Error.send` on failure.
    ///
    /// ## Implementation
    ///
    /// Uses `kill(-pgid, sig)` where the negative PID indicates a process group.
    ///
    /// ## Common Errors
    ///
    /// - `.noPermission` (EPERM): Caller lacks permission to send signal.
    /// - `.noSuchProcess` (ESRCH): No process group with the specified ID exists.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Send SIGTERM to current process group
    /// try ISO_9945.Kernel.Signal.Send.toGroup(.terminate, pgid: .current)
    /// ```

    public static func toGroup(
        _ signal: ISO_9945.Kernel.Signal.Number,
        pgid: ISO_9945.Kernel.Process.Group.ID
    ) throws(ISO_9945.Kernel.Signal.Error) {
        // Negative PID means process group
        guard kill(-pgid.underlying, signal.rawValue) == 0 else {
            throw .send(Error_Primitives.Error.captureErrno())
        }
    }
}
