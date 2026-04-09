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

// MARK: - POSIX error number constants

extension ISO_9945.Kernel.Error.Number {
    /// File or directory does not exist (ENOENT).
    public static var noEntry: Self { Self(__unchecked: (),ENOENT) }

    /// Permission denied (EACCES).
    public static var accessDenied: Self { Self(__unchecked: (),EACCES) }

    /// Operation not permitted (EPERM).
    public static var notPermitted: Self { Self(__unchecked: (),EPERM) }

    /// File or directory already exists (EEXIST).
    public static var exists: Self { Self(__unchecked: (),EEXIST) }

    /// Is a directory (EISDIR).
    public static var isDirectory: Self { Self(__unchecked: (),EISDIR) }

    /// Too many open files in process (EMFILE).
    public static var processLimit: Self { Self(__unchecked: (),EMFILE) }

    /// Too many open files in system (ENFILE).
    public static var systemLimit: Self { Self(__unchecked: (),ENFILE) }

    /// Invalid argument (EINVAL).
    public static var invalid: Self { Self(__unchecked: (),EINVAL) }

    /// Interrupted system call (EINTR).
    public static var interrupted: Self { Self(__unchecked: (),EINTR) }

    /// Resource temporarily unavailable / would block (EAGAIN).
    public static var wouldBlock: Self { Self(__unchecked: (),EAGAIN) }

    /// No such device (ENODEV).
    public static var noDevice: Self { Self(__unchecked: (),ENODEV) }

    /// Not a directory (ENOTDIR).
    public static var notDirectory: Self { Self(__unchecked: (),ENOTDIR) }

    /// Read-only file system (EROFS).
    public static var readOnlyFilesystem: Self { Self(__unchecked: (),EROFS) }

    /// No space left on device (ENOSPC).
    public static var noSpace: Self { Self(__unchecked: (),ENOSPC) }

    /// Bad file descriptor (EBADF).
    public static var badDescriptor: Self { Self(__unchecked: (),EBADF) }

    /// I/O error (EIO).
    public static var ioError: Self { Self(__unchecked: (),EIO) }

    /// Out of memory (ENOMEM).
    public static var noMemory: Self { Self(__unchecked: (),ENOMEM) }
}
