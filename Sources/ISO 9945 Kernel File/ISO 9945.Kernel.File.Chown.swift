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

@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX chown() syscall

extension ISO_9945.Kernel.File.Chown {
    /// Changes the ownership of a file.
    ///
    /// - Parameters:
    ///   - path: The path to the file.
    ///   - uid: The new user ID.
    ///   - gid: The new group ID.
    /// - Throws: `ISO_9945.Kernel.File.Chown.Error` on failure.

    public static func chown(
        path: borrowing Path.Borrowed,
        uid: ISO_9945.Kernel.User.ID,
        gid: ISO_9945.Kernel.Group.ID
    ) throws(Error) {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe _chown(path: cString, uid: uid, gid: gid)
        }
    }

    /// Changes the ownership of a file using a path character pointer.
    ///
    /// - Parameters:
    ///   - path: The path as a pointer to Path.Char (UInt8).
    ///   - uid: The new user ID.
    ///   - gid: The new group ID.
    /// - Throws: `ISO_9945.Kernel.File.Chown.Error` on failure.
    @usableFromInline
    internal static func _chown(
        path: UnsafePointer<Path.Char>,
        uid: ISO_9945.Kernel.User.ID,
        gid: ISO_9945.Kernel.Group.ID
    ) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)
        #if canImport(Darwin)
            let result = unsafe Darwin.chown(cPath, uid.underlying, gid.underlying)
        #elseif canImport(Musl)
            let result = Musl.chown(cPath, uid.underlying, gid.underlying)
        #elseif canImport(Glibc)
            let result = Glibc.chown(cPath, uid.underlying, gid.underlying)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }

    /// Changes the ownership of a symbolic link (not the target).
    ///
    /// - Parameters:
    ///   - path: The path to the symbolic link.
    ///   - uid: The new user ID.
    ///   - gid: The new group ID.
    /// - Throws: `ISO_9945.Kernel.File.Chown.Error` on failure.

    public static func lchown(
        path: borrowing Path.Borrowed,
        uid: ISO_9945.Kernel.User.ID,
        gid: ISO_9945.Kernel.Group.ID
    ) throws(Error) {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe _lchown(path: cString, uid: uid, gid: gid)
        }
    }

    /// Changes the ownership of a symbolic link using a path character pointer.
    ///
    /// - Parameters:
    ///   - path: The path as a pointer to Path.Char (UInt8).
    ///   - uid: The new user ID.
    ///   - gid: The new group ID.
    /// - Throws: `ISO_9945.Kernel.File.Chown.Error` on failure.
    @usableFromInline
    internal static func _lchown(
        path: UnsafePointer<Path.Char>,
        uid: ISO_9945.Kernel.User.ID,
        gid: ISO_9945.Kernel.Group.ID
    ) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)
        #if canImport(Darwin)
            let result = unsafe Darwin.lchown(cPath, uid.underlying, gid.underlying)
        #elseif canImport(Musl)
            let result = Musl.lchown(cPath, uid.underlying, gid.underlying)
        #elseif canImport(Glibc)
            let result = Glibc.lchown(cPath, uid.underlying, gid.underlying)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

// MARK: - POSIX fchown() syscall (raw @_spi(Syscall))

extension ISO_9945.Kernel.File.Chown {
    /// Changes the ownership of an open raw file descriptor.
    ///
    /// Spec-literal raw `fchown(2)`. The typed L2 convenience
    /// (`ISO_9945.Kernel.File.Chown.fchown(_:uid:gid:)` taking
    /// `borrowing ISO_9945.Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameters:
    ///   - fd: The raw file descriptor.
    ///   - uid: The new user ID.
    ///   - gid: The new group ID.
    /// - Throws: `ISO_9945.Kernel.File.Chown.Error` on failure.
    @_spi(Syscall)
    public static func fchown(
        fd: Int32,
        uid: ISO_9945.Kernel.User.ID,
        gid: ISO_9945.Kernel.Group.ID
    ) throws(Error) {
        #if canImport(Darwin)
            let result = unsafe Darwin.fchown(fd, uid.underlying, gid.underlying)
        #elseif canImport(Musl)
            let result = unsafe Musl.fchown(fd, uid.underlying, gid.underlying)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.fchown(fd, uid.underlying, gid.underlying)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

// MARK: - Typed Convenience

extension ISO_9945.Kernel.File.Chown {
    /// Changes the ownership of an open file descriptor.
    ///
    /// Typed L2 form. Delegates to the raw `fchown(fd:uid:gid:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - uid: The new user ID.
    ///   - gid: The new group ID.
    /// - Throws: `ISO_9945.Kernel.File.Chown.Error` on failure.
    public static func fchown(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        uid: ISO_9945.Kernel.User.ID,
        gid: ISO_9945.Kernel.Group.ID
    ) throws(Error) {
        try unsafe fchown(fd: descriptor._rawValue, uid: uid, gid: gid)
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.File.Chown.Error {
    /// Creates an error from the current errno.
    @usableFromInline
    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        switch code {
        case .ENOENT:
            return .path(.notFound)
        case .ENAMETOOLONG:
            return .path(.tooLong)
        case .ELOOP:
            return .path(.loop)
        case .EACCES:
            return .permission(.denied)
        case .EPERM:
            return .permission(.notPermitted)
        case .EROFS:
            return .permission(.readOnlyFilesystem)
        case .EIO:
            return .io(.hardware)
        default:
            return .platform(Error_Primitives.Error(code: code))
        }
    }
}
