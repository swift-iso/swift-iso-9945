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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX mkdir() syscall

extension ISO_9945.Kernel.Directory.Create {
    /// Creates a directory using `Path`.
    ///
    /// This is the preferred entry point.
    ///
    /// - Parameters:
    ///   - path: The path to create.
    ///   - permissions: The permissions for the new directory (default: 0o755).
    /// - Throws: `ISO_9945.Kernel.Directory.Create.Error` on failure.
    public static func create(
        _ path: borrowing Path.Borrowed,
        permissions: ISO_9945.Kernel.File.Permissions = ISO_9945.Kernel.File.Permissions(rawValue: 0o755)
    ) throws(Error) {
        try unsafe path.withUnsafePointer { (ptr: UnsafePointer<Path.Char>) throws(Error) in
            try unsafe _create(ptr, permissions: permissions)
        }
    }

    /// Internal implementation for creating a directory using an unsafe path pointer.
    @usableFromInline
    internal static func _create(
        _ path: UnsafePointer<Path.Char>,
        permissions: ISO_9945.Kernel.File.Permissions = ISO_9945.Kernel.File.Permissions(rawValue: 0o755)
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

    /// Raw POSIX `mkdirat(2)` syscall.
    ///
    /// Spec-literal: takes a raw fd, raw path pointer, returns the raw
    /// result. Zero policy: NO `errno` read, NO error mapping, NO throwing.
    /// The caller inspects the return value and reads `errno` on failure.
    ///
    /// L3-policy throwing wrappers (`POSIX.Kernel.Directory.Create.create(relativeTo:path:permissions:)`
    /// in swift-posix) compose this raw call with `errno`-to-
    /// `ISO_9945.Kernel.Directory.Create.Error` mapping per [PLAT-ARCH-008e]. L1
    /// syscall callers MUST NOT call this function directly; the
    /// L1 → L3-policy → L2 chain is mandatory.
    ///
    /// - Parameters:
    ///   - descriptor: Directory file descriptor.
    ///   - path: Path of the directory to create.
    ///   - permissions: New directory permissions.
    /// - Returns: 0 on success, -1 on failure (`errno` set).
    @_spi(Syscall)
    public static func mkdirat(
        descriptor: Int32,
        path: UnsafePointer<Path.Char>,
        permissions: ISO_9945.Kernel.File.Permissions = ISO_9945.Kernel.File.Permissions(rawValue: 0o755)
    ) -> Int32 {
        let cPath = unsafe UnsafePointer<CChar>(path)

        #if canImport(Darwin)
            return unsafe Darwin.mkdirat(descriptor, cPath, mode_t(permissions.rawValue))
        #elseif canImport(Musl)
            return Musl.mkdirat(descriptor, cPath, mode_t(permissions.rawValue))
        #elseif canImport(Glibc)
            return Glibc.mkdirat(descriptor, cPath, mode_t(permissions.rawValue))
        #else
            return -1
        #endif
    }

    /// Creates a directory relative to a typed descriptor.
    ///
    /// Phase 1.5 typed L2 form. Composes the L2 raw `mkdirat(2)` SPI form
    /// with errno-to-error mapping. The raw form is retained alongside as
    /// `@_spi(Syscall)` for spec-coverage callers.
    ///
    /// - Parameters:
    ///   - path: The path of the directory to create.
    ///   - descriptor: The directory descriptor that `path` is interpreted
    ///     relative to.
    ///   - permissions: The permissions for the new directory (default 0o755).
    /// - Throws: ``Error`` on failure.
    public static func create(
        _ path: borrowing Path.Borrowed,
        relativeTo descriptor: borrowing ISO_9945.Kernel.Descriptor,
        permissions: ISO_9945.Kernel.File.Permissions = ISO_9945.Kernel.File.Permissions(rawValue: 0o755)
    ) throws(Error) {
        let raw = descriptor._rawValue
        try unsafe path.withUnsafePointer { (ptr: UnsafePointer<Path.Char>) throws(Error) in
            let result = unsafe Self.mkdirat(descriptor: raw, path: ptr, permissions: permissions)
            guard result == 0 else {
                throw Error.current()
            }
        }
    }
}

// MARK: - Error

extension ISO_9945.Kernel.Directory.Create {
    public typealias Error = ISO_9945.Kernel.Directory.Create.Error
}

extension ISO_9945.Kernel.Directory.Create.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
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
            return .platform(Error_Primitives.Error(code: code))
        }
    }
}
