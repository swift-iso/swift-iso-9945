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

// MARK: - POSIX errno capture

extension Kernel.Error.Code {
    /// Captures current errno (POSIX only).
    ///
    /// Must be called immediately after a failing syscall, before any other libc call.
    public static func captureErrno() -> Self {
        .posix(errno)
    }

    /// Returns the current errno as an error code.
    ///
    /// Convenience alias for `captureErrno()`.
    public static func current() -> Self {
        captureErrno()
    }
}

// MARK: - POSIX errno constants

extension Kernel.Error.Code {
    /// No error.
    public static let success = Self.posix(0)

    /// No such file or directory (ENOENT).
    public static let ENOENT = Self.posix(Darwin.ENOENT)

    /// Permission denied (EACCES).
    public static let EACCES = Self.posix(Darwin.EACCES)

    /// Operation not permitted (EPERM).
    public static let EPERM = Self.posix(Darwin.EPERM)

    /// File exists (EEXIST).
    public static let EEXIST = Self.posix(Darwin.EEXIST)

    /// Is a directory (EISDIR).
    public static let EISDIR = Self.posix(Darwin.EISDIR)

    /// Not a directory (ENOTDIR).
    public static let ENOTDIR = Self.posix(Darwin.ENOTDIR)

    /// Directory not empty (ENOTEMPTY).
    public static let ENOTEMPTY = Self.posix(Darwin.ENOTEMPTY)

    /// Bad file descriptor (EBADF).
    public static let EBADF = Self.posix(Darwin.EBADF)

    /// Invalid argument (EINVAL).
    public static let EINVAL = Self.posix(Darwin.EINVAL)

    /// Interrupted system call (EINTR).
    public static let EINTR = Self.posix(Darwin.EINTR)

    /// Too many open files (EMFILE).
    public static let EMFILE = Self.posix(Darwin.EMFILE)

    /// Too many open files in system (ENFILE).
    public static let ENFILE = Self.posix(Darwin.ENFILE)

    /// I/O error (EIO).
    public static let EIO = Self.posix(Darwin.EIO)

    /// No space left on device (ENOSPC).
    public static let ENOSPC = Self.posix(Darwin.ENOSPC)

    /// Read-only file system (EROFS).
    public static let EROFS = Self.posix(Darwin.EROFS)

    /// Resource temporarily unavailable (EAGAIN).
    public static let EAGAIN = Self.posix(Darwin.EAGAIN)

    /// Operation would block (EWOULDBLOCK).
    public static let EWOULDBLOCK = Self.posix(Darwin.EWOULDBLOCK)

    /// Cross-device link (EXDEV).
    public static let EXDEV = Self.posix(Darwin.EXDEV)

    /// Too many symbolic links (ELOOP).
    public static let ELOOP = Self.posix(Darwin.ELOOP)

    /// File name too long (ENAMETOOLONG).
    public static let ENAMETOOLONG = Self.posix(Darwin.ENAMETOOLONG)

    /// Not enough memory (ENOMEM).
    public static let ENOMEM = Self.posix(Darwin.ENOMEM)

    /// Broken pipe (EPIPE).
    public static let EPIPE = Self.posix(Darwin.EPIPE)

    /// Connection reset by peer (ECONNRESET).
    public static let ECONNRESET = Self.posix(Darwin.ECONNRESET)

    /// Illegal seek (ESPIPE).
    public static let ESPIPE = Self.posix(Darwin.ESPIPE)

    /// Device or resource busy (EBUSY).
    public static let EBUSY = Self.posix(Darwin.EBUSY)

    /// Too many links (EMLINK).
    public static let EMLINK = Self.posix(Darwin.EMLINK)

    /// Disc quota exceeded (EDQUOT).
    public static let EDQUOT = Self.posix(Darwin.EDQUOT)

    /// Result too large (EOVERFLOW).
    public static let EOVERFLOW = Self.posix(Darwin.EOVERFLOW)

    /// Bad address (EFAULT).
    public static let EFAULT = Self.posix(Darwin.EFAULT)

    /// No locks available (ENOLCK).
    public static let ENOLCK = Self.posix(Darwin.ENOLCK)

    /// Resource deadlock avoided (EDEADLK).
    public static let EDEADLK = Self.posix(Darwin.EDEADLK)

    /// Operation not supported (ENOTSUP).
    public static let ENOTSUP = Self.posix(Darwin.ENOTSUP)
}
