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
public import Binary_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX Memory Allocation

extension ISO_9945.Kernel.Memory.Allocation {
    /// The system's allocation granularity.
    ///
    /// On POSIX systems, this equals the page size.
    ///
    /// Use this for memory mapping offset alignment.
    public static var system: Kernel.Memory.Allocation.Granularity {
        let pageSize = Int(sysconf(Int32(_SC_PAGESIZE)))
        // Safe: page size is always a power of 2
        return Kernel.Memory.Allocation.Granularity(try! Binary.Alignment(pageSize))
    }
}
