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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX mkdir() syscall

extension ISO_9945.Kernel.Directory.Create {
    /// Creates a directory.
    ///
    /// - Parameters:
    ///   - path: The path to create.
    ///   - permissions: The permissions for the new directory (default: 0o755).
    /// - Throws: `Kernel.Directory.Create.Error` on failure.

    public static func create(
        _ path: UnsafePointer<Kernel.Path.Char>,
        permissions: Kernel.File.Permissions = Kernel.File.Permissions(rawValue: 0o755)
    ) throws(Error) {
        let cPath = unsafe UnsafeRawPointer(path).assumingMemoryBound(to: CChar.self)

        #if canImport(Darwin)
            let result = Darwin.mkdir(cPath, mode_t(permissions.rawValue))
        #elseif canImport(Musl)
            let result = Musl.mkdir(cPath, mode_t(permissions.rawValue))
        #elseif canImport(Glibc)
            let result = Glibc.mkdir(cPath, mode_t(permissions.rawValue))
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }

    /// Creates a directory relative to a directory descriptor.
    ///
    /// - Parameters:
    ///   - descriptor: The directory descriptor (or AT_FDCWD for current directory).
    ///   - path: The path to create.
    ///   - permissions: The permissions for the new directory (default: 0o755).
    /// - Throws: `Kernel.Directory.Create.Error` on failure.

    public static func create(
        relativeTo descriptor: Kernel.Descriptor,
        path: UnsafePointer<Kernel.Path.Char>,
        permissions: Kernel.File.Permissions = Kernel.File.Permissions(rawValue: 0o755)
    ) throws(Error) {
        let cPath = unsafe UnsafeRawPointer(path).assumingMemoryBound(to: CChar.self)

        #if canImport(Darwin)
            let result = Darwin.mkdirat(descriptor._rawValue, cPath, mode_t(permissions.rawValue))
        #elseif canImport(Musl)
            let result = Musl.mkdirat(descriptor._rawValue, cPath, mode_t(permissions.rawValue))
        #elseif canImport(Glibc)
            let result = Glibc.mkdirat(descriptor._rawValue, cPath, mode_t(permissions.rawValue))
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }

    // MARK: - Ergonomic Kernel.Path Overloads

    /// Creates a directory using `Kernel.Path`.
    ///
    /// This is the preferred entry point.
    ///
    /// - Parameters:
    ///   - path: The path to create.
    ///   - permissions: The permissions for the new directory (default: 0o755).
    /// - Throws: `Kernel.Directory.Create.Error` on failure.
    public static func create(
        _ path: borrowing Kernel.Path,
        permissions: Kernel.File.Permissions = Kernel.File.Permissions(rawValue: 0o755)
    ) throws(Error) {
        try unsafe path.withUnsafeCString { (ptr: UnsafePointer<Kernel.Path.Char>) throws(Error) in
            try create(ptr, permissions: permissions)
        }
    }
}

// MARK: - Error

extension ISO_9945.Kernel.Directory.Create {
    public typealias Error = Kernel.Directory.Create.Error
}

extension Kernel.Directory.Create.Error {
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
