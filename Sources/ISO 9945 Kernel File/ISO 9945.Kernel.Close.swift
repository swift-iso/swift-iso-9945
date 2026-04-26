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

@_spi(Syscall) import Kernel_Descriptor_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX close() — spec-literal raw

extension Kernel.Close {
    /// Raw POSIX `close(2)` syscall.
    ///
    /// Spec-literal: takes a file descriptor, returns the C-level result.
    /// Zero policy: NO errno read, NO error mapping, NO throwing. The caller
    /// inspects the return value and reads `errno` on failure if needed.
    ///
    /// L3-policy throwing wrappers (`POSIX.Kernel.Close.close(_:)` in
    /// swift-posix) compose this raw call with errno-to-`Kernel.Close.Error`
    /// mapping per [PLAT-ARCH-008e]. L1 syscall callers MUST NOT call this
    /// function directly; the L1 → L3-policy → L2 chain is mandatory.
    ///
    /// - Parameter fd: File descriptor to close.
    /// - Returns: 0 on success, -1 on failure (`errno` set).
    @_spi(Syscall)
    @inlinable
    public static func close(_ fd: Int32) -> Int32 {
        #if canImport(Darwin)
        return Darwin.close(fd)
        #elseif canImport(Glibc)
        return unsafe Glibc.close(fd)
        #elseif canImport(Musl)
        return unsafe Musl.close(fd)
        #else
        return -1
        #endif
    }
}
