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
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Result

extension ISO_9945.Kernel.Process.Fork {
    /// Result of fork() indicating parent or child.
    public enum Result: Sendable, Equatable {
        /// In child process (fork returned 0).
        case child

        /// In parent process with child's PID.
        ///
        /// Label is `child:` not `childPID:` — type already encodes it.
        case parent(child: ISO_9945.Kernel.Process.ID)
    }
}
