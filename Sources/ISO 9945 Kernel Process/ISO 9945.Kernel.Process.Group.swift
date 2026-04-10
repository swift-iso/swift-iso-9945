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

@_spi(Syscall) import Kernel_Descriptor_Primitives

#if canImport(Darwin)
    public import Darwin
#elseif canImport(Glibc)
    public import Glibc
#elseif canImport(Musl)
    public import Musl
#endif

// MARK: - Process Selector

extension ISO_9945.Kernel.Process.Group {
    /// Which process to modify.
    ///
    /// Replaces POSIX "pid=0 means calling process" convention with explicit cases.
    public enum Process: Sendable, Equatable {
        /// The calling process (setpgid pid=0).
        case current

        /// A specific process.
        case id(Kernel.Process.ID)
    }
}

// MARK: - Target Selector

extension ISO_9945.Kernel.Process.Group {
    /// Target process group.
    ///
    /// Replaces POSIX "pgid=0 means use pid as new group" convention with explicit cases.
    public enum Target: Sendable, Equatable {
        /// Use the selected process's PID as the new group ID (setpgid pgid=0).
        ///
        /// If process is `.current`, this uses the caller's PID.
        case same

        /// A specific process group.
        case id(ISO_9945.Kernel.Process.Group.ID)
    }
}

// MARK: - Group Operations

extension ISO_9945.Kernel.Process.Group {
    /// Sets the process group of a process.
    ///
    /// - Parameters:
    ///   - process: Which process to modify.
    ///   - target: Target process group.
    /// - Throws: `ISO_9945.Kernel.Process.Error.group` on failure.
    ///
    /// ## Mapping to setpgid
    ///
    /// | Process | Target | setpgid call |
    /// |---------|--------|--------------|
    /// | `.current` | `.same` | setpgid(0, 0) |
    /// | `.current` | `.id(pgid)` | setpgid(0, pgid) |
    /// | `.id(pid)` | `.same` | setpgid(pid, 0) |
    /// | `.id(pid)` | `.id(pgid)` | setpgid(pid, pgid) |
    ///
    /// ## Common Errors
    ///
    /// - `.noPermission` (EPERM): Permission denied.
    /// - `.noSuchProcess` (ESRCH): No process with specified PID.
    /// - `.invalidArgument` (EINVAL): Invalid process group ID.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Create new process group with current process as leader
    /// try ISO_9945.Kernel.Process.Group.set(.current, to: .same)
    ///
    /// // Move current process to existing group
    /// try ISO_9945.Kernel.Process.Group.set(.current, to: .id(pgid))
    ///
    /// // Move specific process to new group with that process as leader
    /// try ISO_9945.Kernel.Process.Group.set(.id(childPid), to: .same)
    /// ```

    public static func set(
        _ process: Process,
        to target: Target
    ) throws(ISO_9945.Kernel.Process.Error) {
        let pid: pid_t =
            switch process {
            case .current:
                0
            case .id(let id):
                id.rawValue
            }

        let pgid: pid_t =
            switch target {
            case .same:
                0
            case .id(let id):
                id.rawValue
            }

        guard setpgid(pid, pgid) == 0 else {
            throw .group(ISO_9945.Kernel.Error.captureErrno())
        }
    }

    /// Gets the process group of a process.
    ///
    /// - Parameter pid: Process ID (use `.current` for calling process).
    /// - Returns: The process group ID.
    /// - Throws: `ISO_9945.Kernel.Process.Error.group` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.noSuchProcess` (ESRCH): No process with specified PID.
    /// - `.noPermission` (EPERM): Permission denied.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Get process group of current process
    /// let pgid = try ISO_9945.Kernel.Process.Group.id(of: .current)
    ///
    /// // Get process group of another process
    /// let pgid = try ISO_9945.Kernel.Process.Group.id(of: childPid)
    /// ```

    public static func id(of pid: Kernel.Process.ID) throws(ISO_9945.Kernel.Process.Error) -> ID {
        let result = getpgid(pid.rawValue)
        guard result != -1 else {
            throw .group(ISO_9945.Kernel.Error.captureErrno())
        }
        return ID(__unchecked: (), result)
    }
}
