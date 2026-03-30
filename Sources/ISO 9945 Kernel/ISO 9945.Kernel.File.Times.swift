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

// MARK: - POSIX utimensat() syscall

extension ISO_9945.Kernel.File.Times {
    /// Sets the access and modification times of a file.
    ///
    /// - Parameters:
    ///   - path: The path to the file.
    ///   - accessTime: The new access time.
    ///   - modificationTime: The new modification time.
    ///   - followSymlinks: If false, operates on the symlink itself (default: true).
    /// - Throws: `Kernel.File.Times.Error` on failure.

    public static func setTimes(
        path: borrowing Kernel.Path.View,
        accessTime: Kernel.Time,
        modificationTime: Kernel.Time,
        followSymlinks: Bool = true
    ) throws(Error) {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe _setTimes(
                path: cString,
                accessTime: accessTime,
                modificationTime: modificationTime,
                followSymlinks: followSymlinks
            )
        }
    }

    /// Sets the access and modification times of a file using a path character pointer.
    ///
    /// - Parameters:
    ///   - path: The path as a pointer to Path.Char (UInt8).
    ///   - accessTime: The new access time.
    ///   - modificationTime: The new modification time.
    ///   - followSymlinks: If false, operates on the symlink itself (default: true).
    /// - Throws: `Kernel.File.Times.Error` on failure.
    @usableFromInline
    internal static func _setTimes(
        path: UnsafePointer<Path.Char>,
        accessTime: Kernel.Time,
        modificationTime: Kernel.Time,
        followSymlinks: Bool = true
    ) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)
        var times = [timespec](repeating: timespec(), count: 2)

        // Access time
        times[0].tv_sec = time_t(accessTime.secondsSinceUnixEpoch)
        times[0].tv_nsec = Int(accessTime.nanosecondFraction)

        // Modification time
        times[1].tv_sec = time_t(modificationTime.secondsSinceUnixEpoch)
        times[1].tv_nsec = Int(modificationTime.nanosecondFraction)

        let flags: Int32 = followSymlinks ? 0 : AT_SYMLINK_NOFOLLOW

        #if canImport(Darwin)
            let result = unsafe Darwin.utimensat(AT_FDCWD, cPath, &times, flags)
        #elseif canImport(Musl)
            let result = Musl.utimensat(AT_FDCWD, cPath, &times, flags)
        #elseif canImport(Glibc)
            let result = Glibc.utimensat(AT_FDCWD, cPath, &times, flags)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }

    /// Sets the access and modification times of an open file descriptor.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - accessTime: The new access time.
    ///   - modificationTime: The new modification time.
    /// - Throws: `Kernel.File.Times.Error` on failure.
    public static func setTimes(
        _ descriptor: borrowing Kernel.Descriptor,
        accessTime: Kernel.Time,
        modificationTime: Kernel.Time
    ) throws(Error) {
        var times = [timespec](repeating: timespec(), count: 2)

        // Access time
        times[0].tv_sec = time_t(accessTime.secondsSinceUnixEpoch)
        times[0].tv_nsec = Int(accessTime.nanosecondFraction)

        // Modification time
        times[1].tv_sec = time_t(modificationTime.secondsSinceUnixEpoch)
        times[1].tv_nsec = Int(modificationTime.nanosecondFraction)

        #if canImport(Darwin)
            let result = unsafe Darwin.futimens(descriptor._rawValue, &times)
        #elseif canImport(Musl)
            let result = Musl.futimens(descriptor._rawValue, &times)
        #elseif canImport(Glibc)
            let result = Glibc.futimens(descriptor._rawValue, &times)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.File.Times.Error {
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
