// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

@_spi(Syscall) public import Kernel_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX msync flags

extension Kernel.Memory.Map.Sync.Flags {
    /// Synchronous sync - wait for I/O to complete.
    public static let sync = Self(rawValue: MS_SYNC)

    /// Asynchronous sync - schedule I/O but don't wait.
    public static let async = Self(rawValue: MS_ASYNC)

    /// Invalidate cached copies.
    public static let invalidate = Self(rawValue: MS_INVALIDATE)
}
