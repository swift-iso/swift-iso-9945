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

public import Kernel_Primitives_Core
public import Kernel_Descriptor_Primitives
public import Kernel_Error_Primitives
public import Kernel_File_Primitives
public import Kernel_IO_Primitives
public import Kernel_Socket_Primitives
public import Kernel_Memory_Primitives
public import Kernel_Process_Primitives
public import Kernel_Permission_Primitives
public import Kernel_Path_Primitives
public import Kernel_Thread_Primitives
public import Kernel_System_Primitives
public import Kernel_Time_Primitives
public import Kernel_Clock_Primitives
public import Kernel_Random_Primitives
public import Kernel_Environment_Primitives
public import Kernel_Syscall_Primitives
public import Kernel_Terminal_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - madvise Syscall

extension ISO_9945.Kernel.Memory.Map {
    /// Advises the kernel about expected memory access patterns.
    ///
    /// Uses `madvise(2)` to provide hints to the kernel about how
    /// the memory region will be accessed. The kernel may use this
    /// information to optimize read-ahead, paging, and caching behavior.
    ///
    /// - Parameters:
    ///   - addr: The base address of the memory region.
    ///   - length: The length of the region in bytes.
    ///   - advice: The access pattern hint.
    ///
    /// - Note: This is advisory only. The kernel may ignore the hint.
    ///   The function does not throw on failure since advice is optional.
    @unsafe
    public static func advise(
        addr: UnsafeMutableRawPointer,
        length: Kernel.File.Size,
        advice: Kernel.Memory.Map.Advice
    ) {
        // madvise returns -1 on error, but we ignore errors since advice is optional
        _ = unsafe madvise(addr, Int(length.rawValue), advice.rawValue)
    }

    /// Advises the kernel about expected memory access patterns.
    ///
    /// Overload accepting an immutable pointer for read-only mappings.
    @unsafe
    public static func advise(
        addr: UnsafeRawPointer,
        length: Kernel.File.Size,
        advice: Kernel.Memory.Map.Advice
    ) {
        _ = unsafe madvise(UnsafeMutableRawPointer(mutating: addr), Int(length.rawValue), advice.rawValue)
    }
}

#endif
