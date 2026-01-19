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

// MARK: - POSIX mmap flags

extension ISO_9945.Kernel.Memory.Map.Flags {
    /// Shares modifications with other processes mapping the same file.
    public static let shared = Self(rawValue: MAP_SHARED)

    /// Creates a private copy-on-write mapping.
    public static let `private` = Self(rawValue: MAP_PRIVATE)

    /// Creates a mapping not backed by any file.
    public static let anonymous = Self(rawValue: MAP_ANON)

    /// Places mapping at exactly the specified address.
    public static let fixed = Self(rawValue: MAP_FIXED)
}
