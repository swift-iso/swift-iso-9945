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

#if !os(Windows)

import Memory_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Individual Range Locking (mlock/munlock)

extension Memory.Lock {
    /// Locks a memory region into physical RAM.
    ///
    /// Prevents the pages from being paged to swap. Uses `mlock(2)`.
    ///
    /// - Parameters:
    ///   - address: The base address of the region.
    ///   - length: The number of bytes to lock.
    /// - Throws: `Error.lock` on failure.
    ///
    /// ## Platform Notes
    ///
    /// ### macOS
    /// Requires `com.apple.developer.kernel.memory-allocation` entitlement.
    ///
    /// ### Linux
    /// Subject to `RLIMIT_MEMLOCK` resource limit.
    @unsafe
    public static func lock(
        address: UnsafeRawPointer,
        length: Memory.Address.Count
    ) throws(Error) {
        guard unsafe (mlock(address, Int(bitPattern: length.underlying.rawValue)) == 0) else {
            throw .lock(.captureErrno())
        }
    }

    /// Unlocks a memory region, allowing paging.
    ///
    /// Allows the pages to be paged to swap. Uses `munlock(2)`.
    ///
    /// - Parameters:
    ///   - address: The base address of the region.
    ///   - length: The number of bytes to unlock.
    /// - Throws: `Error.unlock` on failure.
    @unsafe
    public static func unlock(
        address: UnsafeRawPointer,
        length: Memory.Address.Count
    ) throws(Error) {
        guard unsafe (munlock(address, Int(bitPattern: length.underlying.rawValue)) == 0) else {
            throw .unlock(.captureErrno())
        }
    }
}

#endif
