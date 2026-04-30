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

@_spi(Syscall) import Kernel_File_Primitives

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

    public static func set(
        access accessTime: Kernel.Time,
        modification modificationTime: Kernel.Time,
        at path: borrowing Path.Borrowed,
        followSymlinks: Bool = true
    ) throws(Error) {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe _set(
                access: accessTime,
                modification: modificationTime,
                path: cString,
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
    internal static func _set(
        access accessTime: Kernel.Time,
        modification modificationTime: Kernel.Time,
        path: UnsafePointer<Path.Char>,
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
}

// MARK: - POSIX futimens() syscall (raw @_spi(Syscall))

extension ISO_9945.Kernel.File.Times {
    /// Sets the access and modification times of a raw file descriptor.
    ///
    /// Spec-literal raw `futimens(2)`. The typed L2 convenience
    /// (`ISO_9945.Kernel.File.Times.set(access:modification:on:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameters:
    ///   - accessTime: The new access time.
    ///   - modificationTime: The new modification time.
    ///   - fd: The raw file descriptor.
    /// - Throws: `Kernel.File.Times.Error` on failure.
    @_spi(Syscall)
    public static func set(
        access accessTime: Kernel.Time,
        modification modificationTime: Kernel.Time,
        fd: Int32
    ) throws(Error) {
        var times = [timespec](repeating: timespec(), count: 2)

        // Access time
        times[0].tv_sec = time_t(accessTime.secondsSinceUnixEpoch)
        times[0].tv_nsec = Int(accessTime.nanosecondFraction)

        // Modification time
        times[1].tv_sec = time_t(modificationTime.secondsSinceUnixEpoch)
        times[1].tv_nsec = Int(modificationTime.nanosecondFraction)

        #if canImport(Darwin)
            let result = unsafe Darwin.futimens(fd, &times)
        #elseif canImport(Musl)
            let result = unsafe Musl.futimens(fd, &times)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.futimens(fd, &times)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

// MARK: - Typed Convenience

extension ISO_9945.Kernel.File.Times {
    /// Sets the access and modification times of an open file descriptor.
    ///
    /// Typed L2 form. Delegates to the raw `set(access:modification:fd:)`
    /// SPI via `descriptor._rawValue`.
    ///
    /// - Parameters:
    ///   - accessTime: The new access time.
    ///   - modificationTime: The new modification time.
    ///   - descriptor: The file descriptor.
    /// - Throws: `Kernel.File.Times.Error` on failure.
    public static func set(
        access accessTime: Kernel.Time,
        modification modificationTime: Kernel.Time,
        on descriptor: borrowing Kernel.Descriptor
    ) throws(Error) {
        try unsafe set(
            access: accessTime,
            modification: modificationTime,
            fd: descriptor._rawValue
        )
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.File.Times.Error {
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
