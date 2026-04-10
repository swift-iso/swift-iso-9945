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

// MARK: - POSIX unlink() syscall

extension ISO_9945.Kernel.File.Delete {
    /// Removes a file or symbolic link.
    ///
    /// - Parameter path: The path to the file to remove.
    /// - Throws: `Kernel.File.Delete.Error` on failure.
    public static func delete(_ path: borrowing Kernel.Path.View) throws(Error) {
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

        try Kernel.Syscall.require(result, .equals(0), orThrow: Error.current())
    }

    /// Removes a file or symbolic link relative to a directory descriptor.
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
        let cPath = unsafe UnsafePointer<CChar>(path)

        #if canImport(Darwin)
            let result = unsafe Darwin.unlinkat(descriptor._rawValue, cPath, flags)
        #elseif canImport(Musl)
            let result = Musl.unlinkat(descriptor._rawValue, cPath, flags)
        #elseif canImport(Glibc)
            let result = Glibc.unlinkat(descriptor._rawValue, cPath, flags)
        #endif

        try Kernel.Syscall.require(result, .equals(0), orThrow: Error.current())
    }
}

// MARK: - Error

extension ISO_9945.Kernel.File.Delete {
    public typealias Error = Kernel.File.Delete.Error
}

extension ISO_9945.Kernel.File.Delete.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Kernel.Error.Code.current()
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
            return .platform(Kernel.Error(code: code))
        }
    }
}
