// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-posix open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-posix project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Kernel_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    public import Glibc
#elseif canImport(Musl)
    public import Musl
#endif

// MARK: - POSIX Standard mlockall Flags

extension Kernel.Memory.Lock.All.Flags {
    /// Lock all pages currently mapped into the address space.
    public static let current = Self(rawValue: MCL_CURRENT)

    /// Lock all pages that become mapped in the future.
    public static let future = Self(rawValue: MCL_FUTURE)
}
