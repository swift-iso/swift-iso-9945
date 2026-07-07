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

// MARK: - Selector

extension ISO_9945.Kernel.Process.Wait {
    /// Selector for which child(ren) to wait for.
    ///
    /// Replaces POSIX magic values (-1, 0, <-1) with explicit cases.
    ///
    /// ## Mapping to waitpid
    ///
    /// | Selector | waitpid pid argument |
    /// |----------|----------------------|
    /// | `.any` | -1 |
    /// | `.process(id)` | id.rawValue |
    /// | `.group(pgid)` | -pgid.rawValue |
    /// | `.current` | 0 |
    public enum Selector: Sendable, Equatable {
        /// Wait for any child process (waitpid pid=-1).
        case any

        /// Wait for a specific child process.
        case process(ISO_9945.Kernel.Process.ID)

        /// Wait for any child in a specific process group.
        case group(ISO_9945.Kernel.Process.Group.ID)

        /// Wait for any child in the calling process's group (waitpid pid=0).
        case current
    }
}
