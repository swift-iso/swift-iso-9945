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

extension ISO_9945.Kernel.Process {
    /// Session operations namespace.
    ///
    /// ## Threading
    ///
    /// Session operations are thread-safe (kernel provides synchronization).
    ///
    /// ## Blocking Behavior
    ///
    /// Operations are synchronous and non-blocking.
    public enum Session {}
}

// MARK: - Session ID

extension ISO_9945.Kernel.Process.Session {
    /// Session ID wrapper.
    ///
    /// A type-safe wrapper for session identifiers.
    public typealias ID = Tagged<ISO_9945.Kernel.Process.Session, Int32>
}

// MARK: - Session Operations

extension ISO_9945.Kernel.Process.Session {
    /// Creates a new session with the calling process as leader.
    ///
    /// - Returns: The new session ID.
    /// - Throws: `ISO_9945.Kernel.Process.Error.session` on failure.
    ///
    /// ## Behavior
    ///
    /// The calling process becomes:
    /// - The leader of a new session
    /// - The leader of a new process group
    /// - Detached from any controlling terminal
    ///
    /// ## Common Errors
    ///
    /// - `.noPermission` (EPERM): The calling process is already a
    ///   process group leader, or the process group ID of another
    ///   process matches the PID of the calling process.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Daemonize: create new session to detach from terminal
    /// switch try ISO_9945.Kernel.Process.Fork.fork() {
    /// case .child:
    ///     let sid = try ISO_9945.Kernel.Process.Session.create()
    ///     // Now running in new session, detached from terminal
    /// case .parent:
    ///     break
    /// }
    /// ```

    public static func create() throws(ISO_9945.Kernel.Process.Error) -> ID {
        let result = setsid()
        guard result != -1 else {
            throw .session(Error_Primitives.Error.captureErrno())
        }
        return ID(__unchecked: (), result)
    }

    /// Gets the session ID of a process.
    ///
    /// - Parameter pid: Process ID (use `.current` for calling process).
    /// - Returns: The session ID.
    /// - Throws: `ISO_9945.Kernel.Process.Error.session` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.noSuchProcess` (ESRCH): No process with the specified PID exists.
    /// - `.noPermission` (EPERM): Permission denied (implementation-defined).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Get session ID of current process
    /// let sid = try ISO_9945.Kernel.Process.Session.id(of: .current)
    ///
    /// // Get session ID of another process
    /// let sid = try ISO_9945.Kernel.Process.Session.id(of: somePid)
    /// ```

    public static func id(of pid: ISO_9945.Kernel.Process.ID) throws(ISO_9945.Kernel.Process.Error) -> ID {
        let result = getsid(pid.rawValue)
        guard result != -1 else {
            throw .session(Error_Primitives.Error.captureErrno())
        }
        return ID(__unchecked: (), result)
    }
}
