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

// MARK: - POSIX chmod() syscall

extension ISO_9945.Kernel.File.Attributes {
    /// Changes the permissions of a file.
    ///
    /// - Parameters:
    ///   - permissions: The new permissions.
    ///   - path: The path to the file.
    /// - Throws: `Kernel.File.Attributes.Error` on failure.

    public static func set(
        _ permissions: Kernel.File.Permissions,
        at path: borrowing Kernel.Path.Borrowed
    ) throws(Error) {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe _set(permissions, path: cString)
        }
    }

    /// Changes the permissions of a file using a path character pointer.
    ///
    /// - Parameters:
    ///   - permissions: The new permissions.
    ///   - path: The path as a pointer to Path.Char (UInt8).
    /// - Throws: `Kernel.File.Attributes.Error` on failure.
    @usableFromInline
    internal static func _set(
        _ permissions: Kernel.File.Permissions,
        path: UnsafePointer<Path.Char>
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
}

// MARK: - POSIX fchmod() syscall (raw @_spi(Syscall))

extension ISO_9945.Kernel.File.Attributes {
    /// Changes the permissions of an open raw file descriptor.
    ///
    /// Spec-literal raw `fchmod(2)`. The typed L2 convenience
    /// (`ISO_9945.Kernel.File.Attributes.set(_:on:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameters:
    ///   - permissions: The new permissions.
    ///   - fd: The raw file descriptor.
    /// - Throws: `Kernel.File.Attributes.Error` on failure.
    @_spi(Syscall)
    public static func set(
        _ permissions: Kernel.File.Permissions,
        fd: Int32
    ) throws(Error) {
        #if canImport(Darwin)
            let result = unsafe Darwin.fchmod(fd, mode_t(permissions.rawValue))
        #elseif canImport(Musl)
            let result = unsafe Musl.fchmod(fd, mode_t(permissions.rawValue))
        #elseif canImport(Glibc)
            let result = unsafe Glibc.fchmod(fd, mode_t(permissions.rawValue))
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

// MARK: - Typed Convenience

extension ISO_9945.Kernel.File.Attributes {
    /// Changes the permissions of an open file descriptor.
    ///
    /// Typed L2 form. Delegates to the raw `set(_:fd:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameters:
    ///   - permissions: The new permissions.
    ///   - descriptor: The file descriptor.
    /// - Throws: `Kernel.File.Attributes.Error` on failure.
    public static func set(
        _ permissions: Kernel.File.Permissions,
        on descriptor: borrowing Kernel.Descriptor
    ) throws(Error) {
        try unsafe set(permissions, fd: descriptor._rawValue)
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.File.Attributes.Error {
    /// Creates an error from the current errno.
    @usableFromInline
    internal static func current() -> Self {
        let code = Kernel.Error.Code.current()
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
            return .platform(Kernel.Error(code: code))
        }
    }
}
