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
    internal import CPOSIXProcessShim
#elseif canImport(Glibc)
    internal import Glibc
    internal import CPOSIXProcessShim
#elseif canImport(Musl)
    internal import Musl
    internal import CPOSIXProcessShim
#endif

extension ISO_9945.Kernel.Process {
    /// Spawn operations namespace.
    public enum Spawn {}
}

// MARK: - Spawn Operation

extension ISO_9945.Kernel.Process.Spawn {
    /// Spawns a new process to execute the specified program.
    ///
    /// Unlike `fork()` followed by `exec()`, `posix_spawn()` does NOT duplicate the
    /// parent's address space. This makes it safe to use from multithreaded Swift
    /// processes (including those running Swift Testing).
    ///
    /// - Parameters:
    ///   - path: Path to the executable (null-terminated C string).
    ///   - argv: Argument vector (null-terminated array of C strings).
    ///   - envp: Environment vector (null-terminated array of C strings).
    /// - Returns: The process ID of the spawned child.
    /// - Throws: `ISO_9945.Kernel.Process.Error.spawn` on failure.
    ///
    /// ## Thread Safety
    ///
    /// This function is safe to call from multithreaded processes. Unlike `fork()`,
    /// it does not duplicate the parent's address space, so it avoids deadlocks
    /// with Swift runtime locks (e.g., `os_unfair_lock`).
    ///
    /// ## Common Errors
    ///
    /// - ENOENT: File not found.
    /// - EACCES: Permission denied.
    /// - ENOEXEC: Invalid executable format.
    /// - ENOMEM: Insufficient memory.
    /// - E2BIG: Argument list too long.
    ///
    /// ## Usage
    ///
    /// Consumers SHOULD use the `Path.Char` overload together with
    /// ``Kernel/Path/Scope/array(_:_:_:)``; that overload is the typed
    /// public entry point. This `CChar` form is kept as an SPI escape
    /// hatch for callers that already own `CChar` pointers.
    ///
    /// ```swift
    /// let argv = ["/usr/bin/true"]
    /// let envp: [String] = []
    ///
    /// let child = try Path.scope.array(argv, envp) { argvPtr, envpPtr in
    ///     try unsafe ISO_9945.Kernel.Process.Spawn.spawn(
    ///         path: argvPtr[0]!,
    ///         argv: argvPtr,
    ///         envp: envpPtr
    ///     )
    /// }
    ///
    /// let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
    /// ```
    @unsafe
    @_spi(Syscall)
    public static func spawn(
        path: UnsafePointer<CChar>,
        argv: UnsafePointer<UnsafePointer<CChar>?>,
        envp: UnsafePointer<UnsafePointer<CChar>?>
    ) throws(ISO_9945.Kernel.Process.Error) -> ISO_9945.Kernel.Process.ID {
        var pid: pid_t = 0

        let rc = unsafe swift_posix_spawn(
            &pid,
            path,
            nil,  // file_actions
            nil,  // attrp
            argv,
            envp
        )

        // posix_spawn returns the error code directly (not via errno)
        guard rc == 0 else {
            throw .spawn(.posix(rc))
        }

        return ISO_9945.Kernel.Process.ID(pid)
    }

    /// Spawns a new process using `Path.Char` pointers.
    ///
    /// This overload bridges from `Path.Char` (UInt8 on POSIX) to `CChar`
    /// for syscall compatibility. Use this with `Path.scope`.
    ///
    /// - Parameters:
    ///   - path: Path to the executable.
    ///   - argv: Argument vector (null-terminated array).
    ///   - envp: Environment vector (null-terminated array).
    /// - Returns: The process ID of the spawned child.
    /// - Throws: `ISO_9945.Kernel.Process.Error.spawn` on failure.
    @unsafe
    public static func spawn(
        path: UnsafePointer<Path.Char>,
        argv: UnsafePointer<UnsafePointer<Path.Char>?>,
        envp: UnsafePointer<UnsafePointer<Path.Char>?>
    ) throws(ISO_9945.Kernel.Process.Error) -> ISO_9945.Kernel.Process.ID {
        // Bridge UInt8 pointers to CChar pointers
        let pathCChar = unsafe UnsafePointer<CChar>(path)
        let argvCChar = unsafe UnsafeRawPointer(argv).assumingMemoryBound(to: UnsafePointer<CChar>?.self)
        let envpCChar = unsafe UnsafeRawPointer(envp).assumingMemoryBound(to: UnsafePointer<CChar>?.self)

        return try unsafe spawn(path: pathCChar, argv: argvCChar, envp: envpCChar)
    }

    /// Spawns a new process with the given actions applied to the child.
    ///
    /// The child inherits the parent's file descriptor table, then applies
    /// each accumulated action in `actions` (dup2 / close / chdir / open)
    /// before `execve(2)`.
    ///
    /// - Parameters:
    ///   - path: Path to the executable (NUL-terminated C string).
    ///   - argv: Argument vector (NULL-terminated array).
    ///   - envp: Environment vector (NULL-terminated array).
    ///   - actions: Builder containing the actions to apply in the child.
    /// - Returns: The process ID of the spawned child.
    /// - Throws: ``ISO_9945/Kernel/Process/Error/spawn(_:)`` on failure.
    @unsafe
    @_spi(Syscall)
    public static func spawn(
        path: UnsafePointer<CChar>,
        argv: UnsafePointer<UnsafePointer<CChar>?>,
        envp: UnsafePointer<UnsafePointer<CChar>?>,
        actions: borrowing Actions
    ) throws(ISO_9945.Kernel.Process.Error) -> ISO_9945.Kernel.Process.ID {
        var pid: pid_t = 0

        let rc = unsafe swift_posix_spawn(
            &pid,
            path,
            actions._handle,
            nil,  // attrp
            argv,
            envp
        )

        guard rc == 0 else {
            throw .spawn(.posix(rc))
        }

        return ISO_9945.Kernel.Process.ID(pid)
    }

    /// Spawns a new process with actions using `Path.Char` pointers.
    ///
    /// - Parameters:
    ///   - path: Path to the executable.
    ///   - argv: Argument vector (NULL-terminated array).
    ///   - envp: Environment vector (NULL-terminated array).
    ///   - actions: Builder containing the actions to apply in the child.
    /// - Returns: The process ID of the spawned child.
    /// - Throws: ``ISO_9945/Kernel/Process/Error/spawn(_:)`` on failure.
    @unsafe
    public static func spawn(
        path: UnsafePointer<Path.Char>,
        argv: UnsafePointer<UnsafePointer<Path.Char>?>,
        envp: UnsafePointer<UnsafePointer<Path.Char>?>,
        actions: borrowing Actions
    ) throws(ISO_9945.Kernel.Process.Error) -> ISO_9945.Kernel.Process.ID {
        let pathCChar = unsafe UnsafePointer<CChar>(path)
        let argvCChar = unsafe UnsafeRawPointer(argv).assumingMemoryBound(to: UnsafePointer<CChar>?.self)
        let envpCChar = unsafe UnsafeRawPointer(envp).assumingMemoryBound(to: UnsafePointer<CChar>?.self)

        return try unsafe spawn(
            path: pathCChar,
            argv: argvCChar,
            envp: envpCChar,
            actions: actions
        )
    }
}
