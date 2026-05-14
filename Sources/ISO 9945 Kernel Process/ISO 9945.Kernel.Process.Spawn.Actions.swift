// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if canImport(Darwin)
    internal import Darwin
    internal import CPOSIXProcessShim
#elseif canImport(Glibc)
    internal import Glibc
    internal import CPOSIXProcessShim
#elseif canImport(Musl)
    internal import Musl
    internal import CPOSIXProcessShim
#endif

extension ISO_9945.Kernel.Process.Spawn {
    /// Builder for `posix_spawn(3)` actions applied to the child: redirecting
    /// stdio, closing inherited descriptors, changing working directory.
    ///
    /// Actions are operations the child process performs immediately after
    /// creation, before `execve(2)`. They are accumulated on the builder and
    /// consumed by ``ISO_9945/Kernel/Process/Spawn/spawn(path:argv:envp:actions:)-(_,_,_,_:borrowing_)``.
    ///
    /// ## Lifecycle
    ///
    /// `Actions` is `~Copyable`: each builder owns a single heap-allocated
    /// `posix_spawn_file_actions_t`. The allocation is freed by `deinit`
    /// after `posix_spawn_file_actions_destroy(3)`.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var actions = try ISO_9945.Kernel.Process.Spawn.Actions()
    /// let pipe = try ISO_9945.Kernel.Pipe.pipe()
    /// try actions.add(dup2: pipe.write, to: .stdout)
    /// try actions.add(close: .init(pipe.read))
    /// let pid = try ISO_9945.Kernel.Process.Spawn.spawn(
    ///     path: pathPtr,
    ///     argv: argvPtr,
    ///     envp: envpPtr,
    ///     actions: actions
    /// )
    /// ```
    @safe
    public struct Actions: ~Copyable {
        @usableFromInline
        internal let _handle: OpaquePointer

        /// Allocate and initialize a new actions builder.
        ///
        /// - Throws: ``ISO_9945/Kernel/Process/Error/spawn(_:)`` on allocation
        ///   or `posix_spawn_file_actions_init(3)` failure.
        public init() throws(ISO_9945.Kernel.Process.Error) {
            var result: Int32 = 0
            guard let raw = unsafe swift_posix_spawn_file_actions_init(&result) else {
                throw .spawn(.posix(result))
            }
            unsafe self._handle = OpaquePointer(raw)
        }

        deinit {
            let typed = unsafe UnsafeMutablePointer<posix_spawn_file_actions_t?>(_handle)
            _ = unsafe swift_posix_spawn_file_actions_destroy(typed)
        }
    }
}

// MARK: - Mutation Operations

extension ISO_9945.Kernel.Process.Spawn.Actions {
    /// Add a `dup2` action.
    ///
    /// In the child, after creation but before `execve(2)`, the fd referred
    /// to by `source` (in the parent's fd table) is duplicated into the
    /// `target` slot. The post-dup child has `target` referring to the same
    /// kernel resource as `source`.
    ///
    /// - Parameters:
    ///   - source: Parent-owned descriptor whose underlying fd is duplicated.
    ///   - target: Slot in the child's fd table to receive the dup.
    public mutating func add(
        dup2 source: borrowing ISO_9945.Kernel.Descriptor,
        to target: Target
    ) throws(ISO_9945.Kernel.Process.Error) {
        let typed = unsafe UnsafeMutablePointer<posix_spawn_file_actions_t?>(_handle)
        let rc = unsafe swift_posix_spawn_file_actions_adddup2(
            typed,
            source._raw,
            target._raw
        )
        guard rc == 0 else { throw .spawn(.posix(rc)) }
    }

    /// Add a `close` action.
    ///
    /// In the child, after creation but before `execve(2)`, the slot named
    /// by `target` is closed.
    ///
    /// - Parameter target: Slot in the child's fd table to close.
    public mutating func add(
        close target: Target
    ) throws(ISO_9945.Kernel.Process.Error) {
        let typed = unsafe UnsafeMutablePointer<posix_spawn_file_actions_t?>(_handle)
        let rc = unsafe swift_posix_spawn_file_actions_addclose(
            typed,
            target._raw
        )
        guard rc == 0 else { throw .spawn(.posix(rc)) }
    }

    /// Add a `chdir` action.
    ///
    /// Wraps `posix_spawn_file_actions_addchdir_np(3)`. In the child, after
    /// creation but before `execve(2)`, the working directory is changed
    /// to `path`.
    ///
    /// The path is copied by libc; the caller's buffer need only outlive
    /// the call.
    ///
    /// - Parameter path: NUL-terminated platform-native path.
    public mutating func add(
        chdir path: UnsafePointer<Path.Char>
    ) throws(ISO_9945.Kernel.Process.Error) {
        let pathCChar = unsafe UnsafePointer<CChar>(path)
        let typed = unsafe UnsafeMutablePointer<posix_spawn_file_actions_t?>(_handle)
        let rc = unsafe swift_posix_spawn_file_actions_addchdir(
            typed,
            pathCChar
        )
        guard rc == 0 else { throw .spawn(.posix(rc)) }
    }

    /// Add an `open` action.
    ///
    /// Wraps `posix_spawn_file_actions_addopen(3)`. In the child, after
    /// creation but before `execve(2)`, `path` is opened with `flags` (and
    /// `mode` if `flags` includes `O_CREAT`) and dup'd into the `target`
    /// slot.
    ///
    /// The path is copied by libc; the caller's buffer need only outlive
    /// the call.
    ///
    /// - Parameters:
    ///   - target: Slot in the child's fd table to receive the opened fd.
    ///   - path: NUL-terminated platform-native path.
    ///   - flags: POSIX `O_*` flags (`O_RDONLY`, `O_WRONLY`, `O_CREAT`, ...).
    ///   - mode: Permission bits applied if `O_CREAT` is in `flags`.
    public mutating func add(
        open target: Target,
        path: UnsafePointer<Path.Char>,
        flags: Int32,
        mode: UInt32
    ) throws(ISO_9945.Kernel.Process.Error) {
        let pathCChar = unsafe UnsafePointer<CChar>(path)
        let typed = unsafe UnsafeMutablePointer<posix_spawn_file_actions_t?>(_handle)
        let rc = unsafe swift_posix_spawn_file_actions_addopen(
            typed,
            target._raw,
            pathCChar,
            flags,
            mode_t(mode)
        )
        guard rc == 0 else { throw .spawn(.posix(rc)) }
    }
}
