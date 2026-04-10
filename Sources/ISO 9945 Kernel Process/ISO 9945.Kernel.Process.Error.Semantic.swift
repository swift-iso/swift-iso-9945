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
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.Process.Error {
    /// Semantic classification of process errors.
    public enum Semantic: Sendable {
        /// Resource limit reached (EAGAIN, ENOMEM).
        case resourceLimit

        /// Operation not permitted (EPERM).
        case noPermission

        /// No such process (ESRCH, ECHILD).
        case noSuchProcess

        /// Interrupted by signal (EINTR).
        case interrupted

        /// Invalid argument (EINVAL).
        case invalidArgument
    }
}
