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

import Memory_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX Memory Allocation

extension Memory.Allocation {
    /// The system's allocation granularity.
    ///
    /// On POSIX systems, this equals the page size.
    ///
    /// Use this for memory mapping offset alignment.
    public static var system: Memory.Allocation.Granularity {
        let raw = sysconf(Int32(_SC_PAGESIZE))
        // sysconf(_SC_PAGESIZE) fails only when the implementation does not
        // recognize the name, which POSIX guarantees it does; a defensive
        // fallback is still used instead of trusting that guarantee blindly,
        // since the alternative is a force-try on a negative value.
        let pageSize = raw > 0 ? Int(raw) : 4096
        // Safe: pageSize is either the platform's reported page size (always
        // a power of 2) or the 4096 fallback, so Memory.Alignment(pageSize)
        // cannot throw.
        // swiftlint:disable:next force_try
        return Memory.Allocation.Granularity(_unchecked: try! Memory.Alignment(pageSize))
    }
}
