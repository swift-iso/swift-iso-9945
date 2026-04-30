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
    /// Kill operations namespace.
    public enum Kill {}
}

// MARK: - Kill Operation

extension ISO_9945.Kernel.Process.Kill {
    /// Sends a signal to a process.
    ///
    /// - Parameters:
    ///   - process: The target process ID.
    ///   - signal: The signal to send.
    /// - Throws: `ISO_9945.Kernel.Process.Error.kill` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.noPermission` (EPERM): Caller lacks permission to send signal.
    /// - `.noSuchProcess` (ESRCH): No process with the specified ID exists.
    /// - `.invalidArgument` (EINVAL): Invalid signal number.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Send SIGTERM to gracefully terminate a process
    /// try ISO_9945.Kernel.Process.Kill.kill(childPID, .terminate)
    ///
    /// // Stop a process (for debugging or synchronization)
    /// try ISO_9945.Kernel.Process.Kill.kill(childPID, .stop)
    ///
    /// // Continue a stopped process
    /// try ISO_9945.Kernel.Process.Kill.kill(childPID, .continue)
    /// ```
    public static func kill(
        _ process: ISO_9945.Kernel.Process.ID,
        _ signal: ISO_9945.Kernel.Signal.Number
    ) throws(ISO_9945.Kernel.Process.Error) {
        #if canImport(Darwin)
            let rc = Darwin.kill(process.rawValue, signal.rawValue)
        #elseif canImport(Glibc)
            let rc = Glibc.kill(process.rawValue, signal.rawValue)
        #elseif canImport(Musl)
            let rc = Musl.kill(process.rawValue, signal.rawValue)
        #endif

        if rc == -1 {
            throw .kill(Error_Primitives.Error.captureErrno())
        }
    }
}
