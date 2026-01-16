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

extension ISO_9945.Kernel.Mkdir {
    /// Creates a directory.
    ///
    /// - Parameters:
    ///   - path: The path to create.
    ///   - permissions: The permissions for the new directory (default: 0o755).
    /// - Throws: `Kernel.Mkdir.Error` on failure.

    public static func mkdir(
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
    /// - Throws: `Kernel.Mkdir.Error` on failure.

    public static func mkdirat(
        _ descriptor: Kernel.Descriptor,
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
}

// MARK: - Error

extension ISO_9945.Kernel.Mkdir {
    public typealias Error = Kernel.Mkdir.Error
}

extension Kernel.Mkdir.Error {
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
