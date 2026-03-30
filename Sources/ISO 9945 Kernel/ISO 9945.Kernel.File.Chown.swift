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
internal import ISO_9945_ABI

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
    /// - Throws: `Kernel.File.Chown.Error` on failure.

    public static func chown(
        path: borrowing Kernel.Path.View,
        uid: Kernel.User.ID,
        gid: Kernel.Group.ID
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
    /// - Throws: `Kernel.File.Chown.Error` on failure.
    @usableFromInline
    internal static func _chown(
        path: UnsafePointer<Path.Char>,
        uid: Kernel.User.ID,
        gid: Kernel.Group.ID
    ) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)
        #if canImport(Darwin)
            let result = unsafe Darwin.chown(cPath, uid.rawValue, gid.rawValue)
        #elseif canImport(Musl)
            let result = Musl.chown(cPath, uid.rawValue, gid.rawValue)
        #elseif canImport(Glibc)
            let result = Glibc.chown(cPath, uid.rawValue, gid.rawValue)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }

    /// Changes the ownership of an open file descriptor.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - uid: The new user ID.
    ///   - gid: The new group ID.
    /// - Throws: `Kernel.File.Chown.Error` on failure.
    public static func fchown(
        _ descriptor: borrowing Kernel.Descriptor,
        uid: Kernel.User.ID,
        gid: Kernel.Group.ID
    ) throws(Error) {
        #if canImport(Darwin)
            let result = Darwin.fchown(descriptor._rawValue, uid.rawValue, gid.rawValue)
        #elseif canImport(Musl)
            let result = Musl.fchown(descriptor._rawValue, uid.rawValue, gid.rawValue)
        #elseif canImport(Glibc)
            let result = Glibc.fchown(descriptor._rawValue, uid.rawValue, gid.rawValue)
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
    /// - Throws: `Kernel.File.Chown.Error` on failure.

    public static func lchown(
        path: borrowing Kernel.Path.View,
        uid: Kernel.User.ID,
        gid: Kernel.Group.ID
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
    /// - Throws: `Kernel.File.Chown.Error` on failure.
    @usableFromInline
    internal static func _lchown(
        path: UnsafePointer<Path.Char>,
        uid: Kernel.User.ID,
        gid: Kernel.Group.ID
    ) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)
        #if canImport(Darwin)
            let result = unsafe Darwin.lchown(cPath, uid.rawValue, gid.rawValue)
        #elseif canImport(Musl)
            let result = Musl.lchown(cPath, uid.rawValue, gid.rawValue)
        #elseif canImport(Glibc)
            let result = Glibc.lchown(cPath, uid.rawValue, gid.rawValue)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.File.Chown.Error {
    /// Creates an error from the current errno.
    @usableFromInline
    internal static func current() -> Self {
        let e = errno
        switch e {
        case ENOENT:
            return .path(.notFound)
        case ENAMETOOLONG:
            return .path(.tooLong)
        case ELOOP:
            return .path(.loop)
        case EACCES:
            return .permission(.denied)
        case EPERM:
            return .permission(.notPermitted)
        case EROFS:
            return .permission(.readOnlyFilesystem)
        case EIO:
            return .io(.hardware)
        default:
            return .platform(Kernel.Error(code: .posix(e)))
        }
    }
}
