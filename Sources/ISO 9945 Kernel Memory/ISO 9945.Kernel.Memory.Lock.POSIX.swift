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

// MARK: - POSIX-Specific Typed API

extension ISO_9945.Kernel.Memory.Lock {
    /// Locks all current and/or future pages using typed flags.
    ///
    /// - Parameter flags: Typed flags for mlockall.
    /// - Throws: `Error.lockAll` on failure.

    public static func lockAll(_ flags: All.Options) throws(Error) {
        try lockAll(flags: flags.rawValue)
    }
}
