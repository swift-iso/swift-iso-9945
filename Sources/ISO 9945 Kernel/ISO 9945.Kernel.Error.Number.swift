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

@_spi(Syscall) public import Kernel_Primitives
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
    public static var noEntry: Self { Self(ENOENT) }

    /// Permission denied (EACCES).
    public static var accessDenied: Self { Self(EACCES) }

    /// Operation not permitted (EPERM).
    public static var notPermitted: Self { Self(EPERM) }

    /// File or directory already exists (EEXIST).
    public static var exists: Self { Self(EEXIST) }

    /// Is a directory (EISDIR).
    public static var isDirectory: Self { Self(EISDIR) }

    /// Too many open files in process (EMFILE).
    public static var processLimit: Self { Self(EMFILE) }

    /// Too many open files in system (ENFILE).
    public static var systemLimit: Self { Self(ENFILE) }

    /// Invalid argument (EINVAL).
    public static var invalid: Self { Self(EINVAL) }

    /// Interrupted system call (EINTR).
    public static var interrupted: Self { Self(EINTR) }

    /// Resource temporarily unavailable / would block (EAGAIN).
    public static var wouldBlock: Self { Self(EAGAIN) }

    /// No such device (ENODEV).
    public static var noDevice: Self { Self(ENODEV) }

    /// Not a directory (ENOTDIR).
    public static var notDirectory: Self { Self(ENOTDIR) }

    /// Read-only file system (EROFS).
    public static var readOnlyFilesystem: Self { Self(EROFS) }

    /// No space left on device (ENOSPC).
    public static var noSpace: Self { Self(ENOSPC) }

    /// Bad file descriptor (EBADF).
    public static var badDescriptor: Self { Self(EBADF) }

    /// I/O error (EIO).
    public static var ioError: Self { Self(EIO) }

    /// Out of memory (ENOMEM).
    public static var noMemory: Self { Self(ENOMEM) }
}
