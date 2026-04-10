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
