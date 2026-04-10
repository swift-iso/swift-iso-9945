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

@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_Socket_Primitives
@_spi(Syscall) public import Kernel_Memory_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_Permission_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_Thread_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Clock_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Syscall_Primitives
@_spi(Syscall) public import Kernel_Terminal_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX mmap() syscalls

extension ISO_9945.Kernel.Memory.Map {
    /// Maps memory into the process address space.
    ///
    /// - Parameters:
    ///   - addr: Suggested address, or `nil` for kernel to choose.
    ///   - length: Number of bytes to map (must be > 0).
    ///   - protection: Memory protection flags.
    ///   - flags: Mapping flags.
    ///   - fd: File descriptor to map, or -1 for anonymous.
    ///   - offset: Offset into the file (must be page-aligned).
    /// - Returns: Pointer to the mapped region.
    /// - Throws: `Error.map` on failure.

    public static func map(
        addr: Kernel.Memory.Address? = nil,
        length: Kernel.File.Size,
        protection: Protection,
        flags: Options,
        fd: borrowing Kernel.Descriptor = .invalid,
        offset: Kernel.File.Offset = .zero
    ) throws(Error) -> Kernel.Memory.Address {
        guard length.isPositive else {
            throw .invalid(.length)
        }

        let result = unsafe mmap(
            addr?.mutablePointer,
            Int(length),
            protection.rawValue,
            flags.rawValue,
            fd._rawValue,
            off_t(offset.rawValue)
        )

        guard unsafe result != MAP_FAILED else {
            throw .map(.captureErrno())
        }

        return unsafe Kernel.Memory.Address(result!)
    }

    /// Unmaps a previously mapped region.
    ///
    /// - Parameters:
    ///   - addr: The base address of the mapping.
    ///   - length: The length of the mapping.
    /// - Throws: `Error.unmap` on failure.

    public static func unmap(
        addr: Kernel.Memory.Address,
        length: Kernel.File.Size
    ) throws(Error) {
        guard unsafe munmap(addr.mutablePointer, Int(length)) == 0 else {
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
        addr: Kernel.Memory.Address,
        length: Kernel.File.Size,
        flags: Sync.Flags = .sync
    ) throws(Error) {
        guard unsafe msync(addr.mutablePointer, Int(length), flags.rawValue) == 0 else {
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
        addr: Kernel.Memory.Address,
        length: Kernel.File.Size,
        protection: Protection
    ) throws(Error) {
        guard unsafe mprotect(addr.mutablePointer, Int(length), protection.rawValue) == 0 else {
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
        addr: Kernel.Memory.Address,
        length: Kernel.File.Size,
        advice: Advice
    ) {
        unsafe _ = madvise(addr.mutablePointer, Int(length), advice.rawValue)
    }
}
