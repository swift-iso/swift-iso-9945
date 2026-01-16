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

// MARK: - POSIX mmap protection

extension Kernel.Memory.Map.Protection {
    /// Permits reading from mapped pages.
    public static let read = Self(rawValue: PROT_READ)

    /// Permits writing to mapped pages.
    public static let write = Self(rawValue: PROT_WRITE)

    /// Permits executing code from mapped pages.
    public static let execute = Self(rawValue: PROT_EXEC)

    /// Convenience for read and write access.
    public static let readWrite = read | write
}
