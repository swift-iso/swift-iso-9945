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
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Signal.Error {
    /// Semantic classification of signal errors.
    public enum Semantic: Sendable {
        /// Invalid signal number (EINVAL).
        case invalidSignal

        /// Operation not permitted (EPERM).
        case noPermission

        /// No such process (ESRCH).
        case noSuchProcess

        /// Interrupted by signal (EINTR).
        case interrupted
    }
}
