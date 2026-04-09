// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-posix open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-posix project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

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

extension ISO_9945.Kernel.Memory.Lock {
    /// Locks all current and/or future pages in the process address space.
    ///
    /// - Parameter flags: Raw flags for mlockall (MCL_CURRENT, MCL_FUTURE, etc.).
    /// - Throws: `Error.lockAll` on failure.
    public static func lockAll(flags: Int32) throws(Error) {
        guard mlockall(flags) == 0 else {
            throw .lockAll(.captureErrno())
        }
    }

    /// Unlocks all pages in the process address space.
    ///
    /// - Throws: `Error.unlockAll` on failure.
    public static func unlockAll() throws(Error) {
        guard munlockall() == 0 else {
            throw .unlockAll(.captureErrno())
        }
    }
}
