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

extension ISO_9945.Kernel.Process {
    /// Exit operations namespace.
    public enum Exit {}
}

// MARK: - Exit Operation

extension ISO_9945.Kernel.Process.Exit {
    /// Terminates the calling process immediately.
    ///
    /// - Parameter status: Exit status code (0-255 meaningful).
    ///
    /// ## Important
    ///
    /// - This function does NOT return.
    /// - Uses `_exit()`, NOT `exit()` — no atexit handlers, no stdio flush.
    /// - Safe to call after `fork()` in the child process.
    ///
    /// ## Exit Code Conventions
    ///
    /// - `0`: Success
    /// - `1-125`: Application-defined errors
    /// - `126`: Command found but not executable
    /// - `127`: Command not found
    /// - `128+N`: Terminated by signal N
    ///
    /// ## Usage
    ///
    /// ```swift
    /// switch try ISO_9945.Kernel.Process.Fork.fork() {
    /// case .child:
    ///     // Do work in child
    ///     ISO_9945.Kernel.Process.Exit.now(0)
    /// case .parent(let child):
    ///     let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
    /// }
    /// ```
    public static func now(_ status: Int32) -> Never {
        _exit(status)
    }

    /// Terminates the calling process normally.
    ///
    /// - Parameter status: Exit status code (0-255 meaningful).
    ///
    /// ## Important
    ///
    /// - This function does NOT return.
    /// - Uses `exit()`, NOT `_exit()` — runs `atexit` handlers and flushes
    ///   stdio buffers before terminating.
    /// - NOT safe to call after `fork()` in the child process: the child
    ///   inherits a *copy* of the parent's unflushed stdio buffers, so
    ///   flushing them writes their contents a second time. Fork children
    ///   must use ``now(_:)``.
    ///
    /// ## Choosing between `normal(_:)` and `now(_:)`
    ///
    /// ISO 9945 defines two termination calls because they serve two
    /// jobs, and the difference is only observable in one direction:
    ///
    /// | | ``normal(_:)`` — `exit(3)` | ``now(_:)`` — `_exit(2)` |
    /// |---|---|---|
    /// | `atexit` handlers | run | skipped |
    /// | stdio buffers | flushed | **discarded** |
    /// | safe after `fork()` | no | yes |
    ///
    /// An ordinary program that terminates itself wants ``normal(_:)``.
    /// Reaching for ``now(_:)`` there is a silent-data-loss hazard rather
    /// than a mere style choice: on a terminal, stdout is line-buffered
    /// and every `print` has already flushed, so the program looks
    /// correct — but the moment its stdout is a pipe or a file it becomes
    /// block-buffered, and `_exit(2)` discards whatever is still in the
    /// buffer. The result is a process that exits 0 having written zero
    /// bytes, and it only misbehaves when its output is being captured.
    ///
    /// ## Exit Code Conventions
    ///
    /// - `0`: Success
    /// - `1-125`: Application-defined errors
    /// - `126`: Command found but not executable
    /// - `127`: Command not found
    /// - `128+N`: Terminated by signal N
    ///
    /// ## Usage
    ///
    /// ```swift
    /// print("done")
    /// ISO_9945.Kernel.Process.Exit.normal(0) // "done" reaches a pipe
    /// ```
    public static func normal(_ status: Int32) -> Never {
        exit(status)
    }
}
