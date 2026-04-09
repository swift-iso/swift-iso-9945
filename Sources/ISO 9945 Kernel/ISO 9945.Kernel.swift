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

// Re-export Terminal and Clock primitives with their POSIX implementations
@_exported public import Terminal_Primitives
@_exported public import Clock_Primitives

extension ISO_9945 {
    /// ISO 9945 (POSIX) kernel mechanisms.
    ///
    /// This is a typealias to `Kernel_Primitives_Core.Kernel`, allowing POSIX-specific
    /// extensions to be added to the shared Kernel type.
    ///
    /// Low-level POSIX syscall wrappers for:
    /// - Signal handling (sigaction, sigprocmask, kill)
    /// - Process control (fork, exec, wait, exit)
    /// - Memory locking (mlockall)
    /// - Dynamic library loading (dlopen, dlsym, dlclose)
    public typealias Kernel = Kernel_Primitives_Core.Kernel
}

// MARK: - POSIX.Kernel.Descriptor Veneer

extension Kernel_Primitives_Core.Kernel.Descriptor {
    /// Creates a descriptor by borrowing a POSIX file descriptor.
    ///
    /// - Parameter fd: The raw POSIX file descriptor (Int32).
    /// - Returns: A `Kernel.Descriptor` wrapping the file descriptor.
    public static func borrowing(_ fd: Int32) -> Self {
        Self(_rawValue: fd)
    }

    /// The raw POSIX file descriptor value.
    public var fileDescriptor: Int32 { _rawValue }
}
