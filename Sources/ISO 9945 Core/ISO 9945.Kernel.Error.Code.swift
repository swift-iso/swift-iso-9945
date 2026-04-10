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

// MARK: - POSIX errno capture

extension ISO_9945.Kernel.Error.Code {
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
//
// Property names mirror POSIX specification terminology per [API-NAME-003].
// Module-qualification is required because property names shadow the global
// errno constants from the platform module.

#if canImport(Darwin)
extension ISO_9945.Kernel.Error.Code {
    public static let success = Self.posix(0)
    public static let ENOENT = Self.posix(Darwin.ENOENT)
    public static let EACCES = Self.posix(Darwin.EACCES)
    public static let EPERM = Self.posix(Darwin.EPERM)
    public static let EEXIST = Self.posix(Darwin.EEXIST)
    public static let EISDIR = Self.posix(Darwin.EISDIR)
    public static let ENOTDIR = Self.posix(Darwin.ENOTDIR)
    public static let ENOTEMPTY = Self.posix(Darwin.ENOTEMPTY)
    public static let EBADF = Self.posix(Darwin.EBADF)
    public static let EINVAL = Self.posix(Darwin.EINVAL)
    public static let EINTR = Self.posix(Darwin.EINTR)
    public static let EMFILE = Self.posix(Darwin.EMFILE)
    public static let ENFILE = Self.posix(Darwin.ENFILE)
    public static let EIO = Self.posix(Darwin.EIO)
    public static let ENOSPC = Self.posix(Darwin.ENOSPC)
    public static let EROFS = Self.posix(Darwin.EROFS)
    public static let EAGAIN = Self.posix(Darwin.EAGAIN)
    public static let EWOULDBLOCK = Self.posix(Darwin.EWOULDBLOCK)
    public static let EXDEV = Self.posix(Darwin.EXDEV)
    public static let ELOOP = Self.posix(Darwin.ELOOP)
    public static let ENAMETOOLONG = Self.posix(Darwin.ENAMETOOLONG)
    public static let ENOMEM = Self.posix(Darwin.ENOMEM)
    public static let EPIPE = Self.posix(Darwin.EPIPE)
    public static let ECONNRESET = Self.posix(Darwin.ECONNRESET)
    public static let ESPIPE = Self.posix(Darwin.ESPIPE)
    public static let EBUSY = Self.posix(Darwin.EBUSY)
    public static let EMLINK = Self.posix(Darwin.EMLINK)
    public static let EDQUOT = Self.posix(Darwin.EDQUOT)
    public static let EOVERFLOW = Self.posix(Darwin.EOVERFLOW)
    public static let EFAULT = Self.posix(Darwin.EFAULT)
    public static let ENOLCK = Self.posix(Darwin.ENOLCK)
    public static let EDEADLK = Self.posix(Darwin.EDEADLK)
    public static let ENOTSUP = Self.posix(Darwin.ENOTSUP)
}
#elseif canImport(Glibc)
extension ISO_9945.Kernel.Error.Code {
    public static let success = Self.posix(0)
    public static let ENOENT = Self.posix(Glibc.ENOENT)
    public static let EACCES = Self.posix(Glibc.EACCES)
    public static let EPERM = Self.posix(Glibc.EPERM)
    public static let EEXIST = Self.posix(Glibc.EEXIST)
    public static let EISDIR = Self.posix(Glibc.EISDIR)
    public static let ENOTDIR = Self.posix(Glibc.ENOTDIR)
    public static let ENOTEMPTY = Self.posix(Glibc.ENOTEMPTY)
    public static let EBADF = Self.posix(Glibc.EBADF)
    public static let EINVAL = Self.posix(Glibc.EINVAL)
    public static let EINTR = Self.posix(Glibc.EINTR)
    public static let EMFILE = Self.posix(Glibc.EMFILE)
    public static let ENFILE = Self.posix(Glibc.ENFILE)
    public static let EIO = Self.posix(Glibc.EIO)
    public static let ENOSPC = Self.posix(Glibc.ENOSPC)
    public static let EROFS = Self.posix(Glibc.EROFS)
    public static let EAGAIN = Self.posix(Glibc.EAGAIN)
    public static let EWOULDBLOCK = Self.posix(Glibc.EWOULDBLOCK)
    public static let EXDEV = Self.posix(Glibc.EXDEV)
    public static let ELOOP = Self.posix(Glibc.ELOOP)
    public static let ENAMETOOLONG = Self.posix(Glibc.ENAMETOOLONG)
    public static let ENOMEM = Self.posix(Glibc.ENOMEM)
    public static let EPIPE = Self.posix(Glibc.EPIPE)
    public static let ECONNRESET = Self.posix(Glibc.ECONNRESET)
    public static let ESPIPE = Self.posix(Glibc.ESPIPE)
    public static let EBUSY = Self.posix(Glibc.EBUSY)
    public static let EMLINK = Self.posix(Glibc.EMLINK)
    public static let EDQUOT = Self.posix(Glibc.EDQUOT)
    public static let EOVERFLOW = Self.posix(Glibc.EOVERFLOW)
    public static let EFAULT = Self.posix(Glibc.EFAULT)
    public static let ENOLCK = Self.posix(Glibc.ENOLCK)
    public static let EDEADLK = Self.posix(Glibc.EDEADLK)
    public static let ENOTSUP = Self.posix(Glibc.ENOTSUP)
}
#elseif canImport(Musl)
extension ISO_9945.Kernel.Error.Code {
    public static let success = Self.posix(0)
    public static let ENOENT = Self.posix(Musl.ENOENT)
    public static let EACCES = Self.posix(Musl.EACCES)
    public static let EPERM = Self.posix(Musl.EPERM)
    public static let EEXIST = Self.posix(Musl.EEXIST)
    public static let EISDIR = Self.posix(Musl.EISDIR)
    public static let ENOTDIR = Self.posix(Musl.ENOTDIR)
    public static let ENOTEMPTY = Self.posix(Musl.ENOTEMPTY)
    public static let EBADF = Self.posix(Musl.EBADF)
    public static let EINVAL = Self.posix(Musl.EINVAL)
    public static let EINTR = Self.posix(Musl.EINTR)
    public static let EMFILE = Self.posix(Musl.EMFILE)
    public static let ENFILE = Self.posix(Musl.ENFILE)
    public static let EIO = Self.posix(Musl.EIO)
    public static let ENOSPC = Self.posix(Musl.ENOSPC)
    public static let EROFS = Self.posix(Musl.EROFS)
    public static let EAGAIN = Self.posix(Musl.EAGAIN)
    public static let EWOULDBLOCK = Self.posix(Musl.EWOULDBLOCK)
    public static let EXDEV = Self.posix(Musl.EXDEV)
    public static let ELOOP = Self.posix(Musl.ELOOP)
    public static let ENAMETOOLONG = Self.posix(Musl.ENAMETOOLONG)
    public static let ENOMEM = Self.posix(Musl.ENOMEM)
    public static let EPIPE = Self.posix(Musl.EPIPE)
    public static let ECONNRESET = Self.posix(Musl.ECONNRESET)
    public static let ESPIPE = Self.posix(Musl.ESPIPE)
    public static let EBUSY = Self.posix(Musl.EBUSY)
    public static let EMLINK = Self.posix(Musl.EMLINK)
    public static let EDQUOT = Self.posix(Musl.EDQUOT)
    public static let EOVERFLOW = Self.posix(Musl.EOVERFLOW)
    public static let EFAULT = Self.posix(Musl.EFAULT)
    public static let ENOLCK = Self.posix(Musl.ENOLCK)
    public static let EDEADLK = Self.posix(Musl.EDEADLK)
    public static let ENOTSUP = Self.posix(Musl.ENOTSUP)
}
#endif
