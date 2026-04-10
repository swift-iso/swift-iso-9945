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

/// POSIX implementation of Terminal stream read operations.

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
public import Terminal_Primitives

extension Terminal.Stream.Read {
    /// Read bytes from this terminal stream.
    ///
    /// Delegates to `Kernel.IO.Read.read(_:Terminal.Stream, into:)` which
    /// performs the raw fd extraction at the C boundary. No `Kernel.Descriptor`
    /// is constructed — standard streams are process-owned and wrapping them
    /// in an owning `~Copyable` Descriptor would close them on deinit.
    ///
    /// - Parameter buffer: Buffer to read bytes into.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    public func callAsFunction(
        into buffer: UnsafeMutableRawBufferPointer
    ) throws(Kernel.IO.Read.Error) -> Int {
        try unsafe Kernel.IO.Read.read(stream, into: buffer)
    }
}

#endif
