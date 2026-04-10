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

@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_Socket_Primitives
@_spi(Syscall) public import Kernel_Memory_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_Permission_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_Thread_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Clock_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Syscall_Primitives
@_spi(Syscall) public import Kernel_Terminal_Primitives
public import ISO_9945
internal import ISO_9945_ABI

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX chmod() syscall

extension ISO_9945.Kernel.File.Attributes {
    /// Changes the permissions of a file.
    ///
    /// - Parameters:
    ///   - path: The path to the file.
    ///   - permissions: The new permissions.
    /// - Throws: `Kernel.File.Attributes.Error` on failure.

    public static func setPermissions(
        path: borrowing Kernel.Path.View,
        permissions: Kernel.File.Permissions
    ) throws(Error) {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe _setPermissions(path: cString, permissions: permissions)
        }
    }

    /// Changes the permissions of a file using a path character pointer.
    ///
    /// - Parameters:
    ///   - path: The path as a pointer to Path.Char (UInt8).
    ///   - permissions: The new permissions.
    /// - Throws: `Kernel.File.Attributes.Error` on failure.
    @usableFromInline
    internal static func _setPermissions(
        path: UnsafePointer<Path.Char>,
        permissions: Kernel.File.Permissions
    ) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)
        #if canImport(Darwin)
            let result = unsafe Darwin.chmod(cPath, mode_t(permissions.rawValue))
        #elseif canImport(Musl)
            let result = Musl.chmod(cPath, mode_t(permissions.rawValue))
        #elseif canImport(Glibc)
            let result = Glibc.chmod(cPath, mode_t(permissions.rawValue))
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }

    /// Changes the permissions of an open file descriptor.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - permissions: The new permissions.
    /// - Throws: `Kernel.File.Attributes.Error` on failure.
    public static func setPermissions(
        _ descriptor: borrowing Kernel.Descriptor,
        permissions: Kernel.File.Permissions
    ) throws(Error) {
        #if canImport(Darwin)
            let result = Darwin.fchmod(descriptor._rawValue, mode_t(permissions.rawValue))
        #elseif canImport(Musl)
            let result = Musl.fchmod(descriptor._rawValue, mode_t(permissions.rawValue))
        #elseif canImport(Glibc)
            let result = Glibc.fchmod(descriptor._rawValue, mode_t(permissions.rawValue))
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.File.Attributes.Error {
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
