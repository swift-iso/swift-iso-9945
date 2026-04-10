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

@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_File_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX stat() syscalls

extension ISO_9945.Kernel.File.Stats {
    /// Gets file metadata for an open file descriptor.
    ///
    /// Retrieves file size, type, permissions, timestamps, and other metadata
    /// using fstat.
    ///
    /// ## Threading
    /// This call may briefly block while reading file metadata. Safe to call
    /// concurrently from multiple threads on the same descriptor.
    ///
    /// ## Errors
    /// - ``Error/handle(_:)``: Invalid descriptor
    /// - ``Error/io(_:)``: I/O error reading metadata
    /// - ``Error/platform(_:)``: Platform-specific error
    ///
    /// - Parameter descriptor: The file descriptor to stat.
    /// - Returns: File metadata including size, type, permissions, and timestamps.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    public static func get(descriptor: borrowing Kernel.Descriptor) throws(Kernel.File.Stats.Error) -> Kernel.File.Stats {
        #if canImport(Darwin)
            var sb = Darwin.stat()
            guard unsafe (Darwin.fstat(descriptor._rawValue, &sb) == 0) else {
                throw Error(posixErrno: errno)
            }
        #elseif canImport(Musl)
            var sb = Musl.stat()
            guard Musl.fstat(descriptor._rawValue, &sb) == 0 else {
                throw Error(posixErrno: errno)
            }
        #elseif canImport(Glibc)
            var sb = Glibc.stat()
            guard Glibc.fstat(descriptor._rawValue, &sb) == 0 else {
                throw Error(posixErrno: errno)
            }
        #endif
        return Kernel.File.Stats(from: sb)
    }

    /// Gets file metadata for a path (follows symlinks).
    ///
    /// Retrieves file size, type, permissions, timestamps, and other metadata
    /// using stat.
    ///
    /// For symlinks, returns info about the target, not the link itself.
    /// Use ``lget(path:)`` to get info about the symlink itself.
    ///
    /// - Parameter path: The path to stat.
    /// - Returns: File metadata including size, type, permissions, and timestamps.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.

    public static func get(path: borrowing Kernel.Path.View) throws(Error) -> Kernel.File.Stats {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe get(unsafePath: UnsafePointer<CChar>(cString))
        }
    }

    /// Gets file metadata for a path using a raw pointer.
    ///
    /// This overload mirrors ``Directory/open(at:)-swift.type.method``'s
    /// `UnsafePointer<Path.Char>` signature for consistency. The ``Path.View``
    /// overload is preferred; use this when you already have a raw pointer.
    ///
    /// - Parameter path: Null-terminated path pointer.
    /// - Returns: File metadata.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    @unsafe
    public static func get(at path: UnsafePointer<Path.Char>) throws(Error) -> Kernel.File.Stats {
        try unsafe get(unsafePath: UnsafePointer<CChar>(path))
    }

    /// Gets file metadata for a path using an unsafe C string pointer.
    ///
    /// - Parameter unsafePath: Null-terminated path string.
    /// - Returns: File metadata.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    internal static func get(unsafePath path: UnsafePointer<CChar>) throws(Error) -> Kernel.File.Stats {
        #if canImport(Darwin)
            var sb = Darwin.stat()
            guard unsafe (stat(path, &sb) == 0) else {
                throw Error(posixErrno: errno)
            }
        #elseif canImport(Musl)
            var sb = Musl.stat()
            guard stat(path, &sb) == 0 else {
                throw Error(posixErrno: errno)
            }
        #elseif canImport(Glibc)
            var sb = Glibc.stat()
            guard stat(path, &sb) == 0 else {
                throw Error(posixErrno: errno)
            }
        #endif
        return Kernel.File.Stats(from: sb)
    }

    /// Gets file metadata for a path without following symlinks.
    ///
    /// For symlinks, returns info about the link itself rather than its target.
    /// Useful for cycle detection when walking directories.
    ///
    /// - Parameter path: The path to stat.
    /// - Returns: File metadata including size, type, permissions, and timestamps.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.

    public static func lget(path: borrowing Kernel.Path.View) throws(Error) -> Kernel.File.Stats {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe lget(unsafePath: UnsafePointer<CChar>(cString))
        }
    }

    /// Gets file metadata for a path without following symlinks using a raw pointer.
    ///
    /// This overload mirrors ``Directory/open(at:)-swift.type.method``'s
    /// `UnsafePointer<Path.Char>` signature for consistency.
    ///
    /// - Parameter path: Null-terminated path pointer.
    /// - Returns: File metadata.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    @unsafe
    public static func lget(at path: UnsafePointer<Path.Char>) throws(Error) -> Kernel.File.Stats {
        try unsafe lget(unsafePath: UnsafePointer<CChar>(path))
    }

    /// Gets file metadata for a path without following symlinks using an unsafe C string pointer.
    ///
    /// - Parameter unsafePath: Null-terminated path string.
    /// - Returns: File metadata.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    internal static func lget(unsafePath path: UnsafePointer<CChar>) throws(Error) -> Kernel.File.Stats {
        #if canImport(Darwin)
            var sb = Darwin.stat()
            guard unsafe (Darwin.lstat(path, &sb) == 0) else {
                throw Error(posixErrno: errno)
            }
        #elseif canImport(Musl)
            var sb = Musl.stat()
            guard Musl.lstat(path, &sb) == 0 else {
                throw Error(posixErrno: errno)
            }
        #elseif canImport(Glibc)
            var sb = Glibc.stat()
            guard Glibc.lstat(path, &sb) == 0 else {
                throw Error(posixErrno: errno)
            }
        #endif
        return Kernel.File.Stats(from: sb)
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.File.Stats.Error {
    internal init(posixErrno code: Int32) {
        let errorCode = Kernel.Error.Code.posix(code)
        if let e = Kernel.Descriptor.Validity.Error(code: errorCode) {
            self = .handle(e)
            return
        }
        if let e = Kernel.IO.Error(code: errorCode) {
            self = .io(e)
            return
        }
        self = .platform(Kernel.Error(code: errorCode))
    }
}

// MARK: - Stats Construction from POSIX stat

@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_File_Primitives

#if canImport(Darwin)
extension ISO_9945.Kernel.File.Stats {
    /// Creates a Kernel.File.Stats from a POSIX stat structure.
    internal init(from sb: Darwin.stat) {
        let atime = Kernel.Time(__unchecked: (), secondsSinceUnixEpoch: Int64(sb.st_atimespec.tv_sec), nanosecondFraction: Int32(sb.st_atimespec.tv_nsec))
        let mtime = Kernel.Time(__unchecked: (), secondsSinceUnixEpoch: Int64(sb.st_mtimespec.tv_sec), nanosecondFraction: Int32(sb.st_mtimespec.tv_nsec))
        let ctime = Kernel.Time(__unchecked: (), secondsSinceUnixEpoch: Int64(sb.st_ctimespec.tv_sec), nanosecondFraction: Int32(sb.st_ctimespec.tv_nsec))

        self.init(
            size: Kernel.File.Size(Int64(sb.st_size)),
            type: Kind(mode: sb.st_mode),
            permissions: Kernel.File.Permissions(rawValue: UInt16(sb.st_mode & 0o7777)),
            uid: Kernel.User.ID(__unchecked: (), UInt32(sb.st_uid)),
            gid: Kernel.Group.ID(__unchecked: (), UInt32(sb.st_gid)),
            inode: Kernel.Inode(UInt64(sb.st_ino)),
            device: Kernel.Device(UInt64(sb.st_dev)),
            linkCount: Kernel.Link.Count(__unchecked: (), Cardinal(UInt(sb.st_nlink))),
            accessTime: atime,
            modificationTime: mtime,
            changeTime: ctime
        )
    }
}
#elseif canImport(Glibc)
extension ISO_9945.Kernel.File.Stats {
    /// Creates a Kernel.File.Stats from a POSIX stat structure.
    internal init(from sb: Glibc.stat) {
        let atime = Kernel.Time(__unchecked: (), secondsSinceUnixEpoch: Int64(sb.st_atim.tv_sec), nanosecondFraction: Int32(sb.st_atim.tv_nsec))
        let mtime = Kernel.Time(__unchecked: (), secondsSinceUnixEpoch: Int64(sb.st_mtim.tv_sec), nanosecondFraction: Int32(sb.st_mtim.tv_nsec))
        let ctime = Kernel.Time(__unchecked: (), secondsSinceUnixEpoch: Int64(sb.st_ctim.tv_sec), nanosecondFraction: Int32(sb.st_ctim.tv_nsec))

        self.init(
            size: Kernel.File.Size(Int64(sb.st_size)),
            type: Kind(mode: sb.st_mode),
            permissions: Kernel.File.Permissions(rawValue: UInt16(sb.st_mode & 0o7777)),
            uid: Kernel.User.ID(__unchecked: (), UInt32(sb.st_uid)),
            gid: Kernel.Group.ID(__unchecked: (), UInt32(sb.st_gid)),
            inode: Kernel.Inode(UInt64(sb.st_ino)),
            device: Kernel.Device(UInt64(sb.st_dev)),
            linkCount: Kernel.Link.Count(__unchecked: (), Cardinal(UInt(sb.st_nlink))),
            accessTime: atime,
            modificationTime: mtime,
            changeTime: ctime
        )
    }
}
#elseif canImport(Musl)
extension ISO_9945.Kernel.File.Stats {
    /// Creates a Kernel.File.Stats from a POSIX stat structure.
    internal init(from sb: Musl.stat) {
        let atime = Kernel.Time(__unchecked: (), secondsSinceUnixEpoch: Int64(sb.st_atim.tv_sec), nanosecondFraction: Int32(sb.st_atim.tv_nsec))
        let mtime = Kernel.Time(__unchecked: (), secondsSinceUnixEpoch: Int64(sb.st_mtim.tv_sec), nanosecondFraction: Int32(sb.st_mtim.tv_nsec))
        let ctime = Kernel.Time(__unchecked: (), secondsSinceUnixEpoch: Int64(sb.st_ctim.tv_sec), nanosecondFraction: Int32(sb.st_ctim.tv_nsec))

        self.init(
            size: Kernel.File.Size(Int64(sb.st_size)),
            type: Kind(mode: sb.st_mode),
            permissions: Kernel.File.Permissions(rawValue: UInt16(sb.st_mode & 0o7777)),
            uid: Kernel.User.ID(__unchecked: (), UInt32(sb.st_uid)),
            gid: Kernel.Group.ID(__unchecked: (), UInt32(sb.st_gid)),
            inode: Kernel.Inode(UInt64(sb.st_ino)),
            device: Kernel.Device(UInt64(sb.st_dev)),
            linkCount: Kernel.Link.Count(__unchecked: (), Cardinal(UInt(sb.st_nlink))),
            accessTime: atime,
            modificationTime: mtime,
            changeTime: ctime
        )
    }
}
#endif

// MARK: - File Kind from POSIX mode

extension ISO_9945.Kernel.File.Stats.Kind {
    /// Creates a file type from POSIX st_mode.
    internal init(mode: mode_t) {
        let fileType = mode & S_IFMT
        switch fileType {
        case S_IFREG:
            self = .regular
        case S_IFDIR:
            self = .directory
        case S_IFLNK:
            self = .link(.symbolic)
        case S_IFBLK:
            self = .device(.block)
        case S_IFCHR:
            self = .device(.character)
        case S_IFIFO:
            self = .fifo
        case S_IFSOCK:
            self = .socket
        default:
            self = .unknown
        }
    }
}
