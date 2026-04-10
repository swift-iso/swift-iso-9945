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
