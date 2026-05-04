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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX error number type
//
// `Error_Primitives.Error.Number` is the POSIX errno-shaped (Int32) tagged wrapper.
// The Windows (UInt32) counterpart is declared by `swift-windows-standard`.
// Each platform package contributes the typealias that is correct for its
// platform per [PLAT-ARCH-008c]; consumers see a single unified name via
// the re-export chain exposed by `import Kernel`.

extension Error_Primitives.Error {
    /// Platform error number (POSIX errno).
    ///
    /// A type-safe wrapper for POSIX errno values.
    public typealias Number = Tagged<Error_Primitives.Error, Int32>
}

// MARK: - POSIX error number constants

extension Error_Primitives.Error.Number {
    /// File or directory does not exist (ENOENT).
    public static var noEntry: Self { Self(_unchecked: ENOENT) }

    /// Permission denied (EACCES).
    public static var accessDenied: Self { Self(_unchecked: EACCES) }

    /// Operation not permitted (EPERM).
    public static var notPermitted: Self { Self(_unchecked: EPERM) }

    /// File or directory already exists (EEXIST).
    public static var exists: Self { Self(_unchecked: EEXIST) }

    /// Is a directory (EISDIR).
    public static var isDirectory: Self { Self(_unchecked: EISDIR) }

    /// Too many open files in process (EMFILE).
    public static var processLimit: Self { Self(_unchecked: EMFILE) }

    /// Too many open files in system (ENFILE).
    public static var systemLimit: Self { Self(_unchecked: ENFILE) }

    /// Invalid argument (EINVAL).
    public static var invalid: Self { Self(_unchecked: EINVAL) }

    /// Interrupted system call (EINTR).
    public static var interrupted: Self { Self(_unchecked: EINTR) }

    /// Resource temporarily unavailable / would block (EAGAIN).
    public static var wouldBlock: Self { Self(_unchecked: EAGAIN) }

    /// No such device (ENODEV).
    public static var noDevice: Self { Self(_unchecked: ENODEV) }

    /// Not a directory (ENOTDIR).
    public static var notDirectory: Self { Self(_unchecked: ENOTDIR) }

    /// Read-only file system (EROFS).
    public static var readOnlyFilesystem: Self { Self(_unchecked: EROFS) }

    /// No space left on device (ENOSPC).
    public static var noSpace: Self { Self(_unchecked: ENOSPC) }

    /// Bad file descriptor (EBADF).
    public static var badDescriptor: Self { Self(_unchecked: EBADF) }

    /// I/O error (EIO).
    public static var ioError: Self { Self(_unchecked: EIO) }

    /// Out of memory (ENOMEM).
    public static var noMemory: Self { Self(_unchecked: ENOMEM) }
}
