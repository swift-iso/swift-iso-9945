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
