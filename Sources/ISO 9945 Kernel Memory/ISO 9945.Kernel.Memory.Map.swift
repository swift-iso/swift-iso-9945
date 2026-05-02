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

@_spi(Syscall) import ISO_9945_Core

import Memory_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX mmap() syscalls

extension Memory.Map {
    /// Maps memory into the process address space (raw `mmap(2)`).
    ///
    /// Spec-literal: takes a raw fd, returns the mapped region or throws on
    /// failure. The L3-policy typed-descriptor convenience lives on the
    /// unified `Memory.Map` namespace at swift-posix per
    /// [PLAT-ARCH-005] / [PLAT-ARCH-008e].
    ///
    /// - Parameters:
    ///   - addr: Suggested address, or `nil` for kernel to choose.
    ///   - length: Number of bytes to map (must be > 0).
    ///   - protection: Memory protection flags.
    ///   - flags: Mapping flags.
    ///   - fd: Raw file descriptor to map, or `-1` for anonymous.
    ///   - offset: Offset into the file (must be page-aligned).
    /// - Returns: Pointer to the mapped region.
    /// - Throws: `Error.map` on failure.
    internal static func map(
        addr: Memory.Address? = nil,
        length: Memory.Address.Count,
        protection: Protection,
        flags: Options,
        fd: Int32 = -1,
        offset: ISO_9945.Kernel.File.Offset = .zero
    ) throws(Error) -> Memory.Address {
        guard length.rawValue.rawValue > 0 else {
            throw .invalid(.length)
        }

        let result = unsafe mmap(
            addr?.mutablePointer,
            Int(bitPattern: length.rawValue.rawValue),
            protection.rawValue,
            flags.rawValue,
            fd,
            off_t(offset.rawValue)
        )

        guard unsafe result != MAP_FAILED else {
            throw .map(.captureErrno())
        }

        return unsafe Memory.Address(result!)
    }

    /// Maps memory into the process address space using a typed descriptor.
    ///
    /// Phase 1.5 typed L2 form. Delegates to the raw `map(... fd: Int32, ...)`
    /// SPI via `descriptor._rawValue`.
    public static func map(
        addr: Memory.Address? = nil,
        length: Memory.Address.Count,
        protection: Protection,
        flags: Options,
        descriptor: borrowing ISO_9945.Kernel.Descriptor,
        offset: ISO_9945.Kernel.File.Offset = .zero
    ) throws(Error) -> Memory.Address {
        try map(
            addr: addr,
            length: length,
            protection: protection,
            flags: flags,
            fd: descriptor._rawValue,
            offset: offset
        )
    }

    /// Unmaps a previously mapped region.
    ///
    /// - Parameters:
    ///   - addr: The base address of the mapping.
    ///   - length: The length of the mapping.
    /// - Throws: `Error.unmap` on failure.

    public static func unmap(
        addr: Memory.Address,
        length: Memory.Address.Count
    ) throws(Error) {
        guard unsafe munmap(addr.mutablePointer, Int(bitPattern: length.rawValue.rawValue)) == 0 else {
            throw .unmap(.captureErrno())
        }
    }

    /// Unmaps a mapped region.
    ///
    /// - Parameter region: The region to unmap.
    /// - Throws: `Error.unmap` on failure.

    public static func unmap(_ region: Region) throws(Error) {
        try unmap(addr: region.base, length: region.length)
    }

    /// Synchronizes a mapped region to disk.
    ///
    /// - Parameters:
    ///   - addr: The base address of the region.
    ///   - length: The length of the region.
    ///   - flags: Sync flags (sync, async, invalidate).
    /// - Throws: `Error.sync` on failure.

    public static func sync(
        addr: Memory.Address,
        length: Memory.Address.Count,
        flags: Sync.Options = .sync
    ) throws(Error) {
        guard unsafe msync(addr.mutablePointer, Int(bitPattern: length.rawValue.rawValue), flags.rawValue) == 0 else {
            throw .sync(.captureErrno())
        }
    }

    /// Changes the protection on a mapped region.
    ///
    /// - Parameters:
    ///   - addr: The base address (must be page-aligned).
    ///   - length: The length of the region.
    ///   - protection: The new protection flags.
    /// - Throws: `Error.protect` on failure.

    public static func protect(
        addr: Memory.Address,
        length: Memory.Address.Count,
        protection: Protection
    ) throws(Error) {
        guard unsafe mprotect(addr.mutablePointer, Int(bitPattern: length.rawValue.rawValue), protection.rawValue) == 0 else {
            throw .protect(.captureErrno())
        }
    }

    /// Advises the kernel about expected access patterns.
    ///
    /// This is advisory only; errors are ignored.
    ///
    /// - Parameters:
    ///   - addr: The base address.
    ///   - length: The length of the region.
    ///   - advice: The advice type.

    public static func advise(
        addr: Memory.Address,
        length: Memory.Address.Count,
        advice: Advice
    ) {
        unsafe _ = madvise(addr.mutablePointer, Int(bitPattern: length.rawValue.rawValue), advice.rawValue)
    }
}
