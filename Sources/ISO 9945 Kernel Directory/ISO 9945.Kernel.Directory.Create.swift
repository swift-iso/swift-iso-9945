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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX mkdir() syscall

extension ISO_9945.Kernel.Directory.Create {
    /// Creates a directory using `Kernel.Path`.
    ///
    /// This is the preferred entry point.
    ///
    /// - Parameters:
    ///   - path: The path to create.
    ///   - permissions: The permissions for the new directory (default: 0o755).
    /// - Throws: `Kernel.Directory.Create.Error` on failure.
    public static func create(
        _ path: borrowing Kernel.Path.Borrowed,
        permissions: Kernel.File.Permissions = Kernel.File.Permissions(rawValue: 0o755)
    ) throws(Error) {
        try unsafe path.withUnsafePointer { (ptr: UnsafePointer<Path.Char>) throws(Error) in
            try unsafe _create(ptr, permissions: permissions)
        }
    }

    /// Internal implementation for creating a directory using an unsafe path pointer.
    @usableFromInline
    internal static func _create(
        _ path: UnsafePointer<Path.Char>,
        permissions: Kernel.File.Permissions = Kernel.File.Permissions(rawValue: 0o755)
    ) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)

        #if canImport(Darwin)
            let result = unsafe Darwin.mkdir(cPath, mode_t(permissions.rawValue))
        #elseif canImport(Musl)
            let result = Musl.mkdir(cPath, mode_t(permissions.rawValue))
        #elseif canImport(Glibc)
            let result = Glibc.mkdir(cPath, mode_t(permissions.rawValue))
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }

    /// Internal implementation for creating a directory relative to a descriptor.
    @usableFromInline
    internal static func _create(
        relativeTo descriptor: borrowing Kernel.Descriptor,
        path: UnsafePointer<Path.Char>,
        permissions: Kernel.File.Permissions = Kernel.File.Permissions(rawValue: 0o755)
    ) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)

        #if canImport(Darwin)
            let result = unsafe Darwin.mkdirat(descriptor._rawValue, cPath, mode_t(permissions.rawValue))
        #elseif canImport(Musl)
            let result = Musl.mkdirat(descriptor._rawValue, cPath, mode_t(permissions.rawValue))
        #elseif canImport(Glibc)
            let result = Glibc.mkdirat(descriptor._rawValue, cPath, mode_t(permissions.rawValue))
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

// MARK: - Error

extension ISO_9945.Kernel.Directory.Create {
    public typealias Error = Kernel.Directory.Create.Error
}

extension ISO_9945.Kernel.Directory.Create.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Kernel.Error.Code.current()
        switch code {
        case .ENOENT:
            return .notFound
        case .EACCES, .EPERM:
            return .permission
        case .EEXIST:
            return .exists
        case .ENOTDIR:
            return .notDirectory
        case .EROFS:
            return .readOnly
        case .ENOSPC:
            return .noSpace
        case .ELOOP:
            return .loop
        case .ENAMETOOLONG:
            return .nameTooLong
        default:
            return .platform(Kernel.Error(code: code))
        }
    }
}
