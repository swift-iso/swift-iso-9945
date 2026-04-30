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

// MARK: - POSIX unlink() syscall

extension ISO_9945.Kernel.File.Delete {
    /// Removes a file or symbolic link.
    ///
    /// - Parameter path: The path to the file to remove.
    /// - Throws: `Kernel.File.Delete.Error` on failure.
    public static func delete(_ path: borrowing Path.Borrowed) throws(Error) {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe _delete(cString)
        }
    }

    /// Internal implementation for removing a file using an unsafe path pointer.
    @usableFromInline
    internal static func _delete(_ path: UnsafePointer<Path.Char>) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)

        #if canImport(Darwin)
            let result = unsafe Darwin.unlink(cPath)
        #elseif canImport(Musl)
            let result = Musl.unlink(cPath)
        #elseif canImport(Glibc)
            let result = Glibc.unlink(cPath)
        #endif

        try Syscall.require(result, .equals(0), orThrow: Error.current())
    }
}

// MARK: - POSIX unlinkat() syscall (raw @_spi(Syscall))

extension ISO_9945.Kernel.File.Delete {
    /// Removes a file or symbolic link relative to a raw directory descriptor.
    ///
    /// Spec-literal raw `unlinkat(2)`. The typed L2 internal-only convenience
    /// (`ISO_9945.Kernel.File.Delete._delete(relativeTo:path:flags:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameters:
    ///   - fd: Raw directory descriptor (or AT_FDCWD for current directory).
    ///   - path: The path to the file to remove.
    ///   - flags: Options to control the operation (e.g., AT_REMOVEDIR).
    /// - Throws: `Kernel.File.Delete.Error` on failure.
    @_spi(Syscall)
    public static func delete(
        fd: Int32,
        path: UnsafePointer<Path.Char>,
        flags: Int32 = 0
    ) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)

        #if canImport(Darwin)
            let result = unsafe Darwin.unlinkat(fd, cPath, flags)
        #elseif canImport(Musl)
            let result = unsafe Musl.unlinkat(fd, cPath, flags)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.unlinkat(fd, cPath, flags)
        #endif

        try Syscall.require(result, .equals(0), orThrow: Error.current())
    }
}

// MARK: - Typed Convenience (internal)

extension ISO_9945.Kernel.File.Delete {
    /// Removes a file or symbolic link relative to a directory descriptor.
    ///
    /// Internal typed L2 form. Delegates to the raw `delete(fd:path:flags:)`
    /// SPI via `descriptor._rawValue`.
    ///
    /// - Parameters:
    ///   - descriptor: The directory descriptor (or AT_FDCWD for current directory).
    ///   - path: The path to the file to remove.
    ///   - flags: Options to control the operation (e.g., AT_REMOVEDIR).
    /// - Throws: `Kernel.File.Delete.Error` on failure.
    @usableFromInline
    internal static func _delete(
        relativeTo descriptor: borrowing Kernel.Descriptor,
        path: UnsafePointer<Path.Char>,
        flags: Int32 = 0
    ) throws(Error) {
        try unsafe delete(fd: descriptor._rawValue, path: path, flags: flags)
    }
}

// MARK: - Error

extension ISO_9945.Kernel.File.Delete {
    public typealias Error = Kernel.File.Delete.Error
}

extension ISO_9945.Kernel.File.Delete.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        switch code {
        case .ENOENT:
            return .notFound
        case .EACCES, .EPERM:
            return .permission
        case .EISDIR:
            return .isDirectory
        case .ENOTDIR:
            return .notDirectory
        case .EROFS:
            return .readOnly
        case .EBUSY:
            return .busy
        case .ELOOP:
            return .loop
        case .ENAMETOOLONG:
            return .nameTooLong
        default:
            return .platform(Error_Primitives.Error(code: code))
        }
    }
}
