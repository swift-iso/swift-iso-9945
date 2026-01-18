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

// MARK: - POSIX open() syscall

extension ISO_9945.Kernel.File.Open {
    /// Opens a file at the specified path.
    ///
    /// ## Threading
    /// This call blocks until the open completes. The open syscall may block
    /// on networked filesystems or when opening FIFOs/device files.
    ///
    /// ## Descriptor Ownership
    /// The caller receives ownership of the returned descriptor and must close it
    /// explicitly via ``Kernel/Close/close(_:)``. Failing to close leaks the
    /// kernel resource until process termination.
    ///
    /// ## Errors
    /// - ``Error/notFound``: Path does not exist and `.create` not specified
    /// - ``Error/exists``: Path exists and `.exclusive` was specified
    /// - ``Error/permission``: Insufficient permissions for requested mode
    /// - ``Error/isDirectory``: Cannot open directory with write mode
    /// - ``Error/tooManyOpen``: Process or system descriptor limit reached
    ///
    /// - Parameters:
    ///   - path: The file path to open.
    ///   - mode: Read/write access mode.
    ///   - options: Creation and behavior options.
    ///   - permissions: POSIX permissions for newly created files.
    /// - Returns: A file descriptor for the opened file.
    /// - Throws: ``Kernel/File/Open/Error`` on failure.

    public static func open(
        path: borrowing Kernel.Path,
        mode: Kernel.File.Open.Mode,
        options: Kernel.File.Open.Options,
        permissions: Kernel.File.Permissions
    ) throws(Kernel.File.Open.Error) -> Kernel.Descriptor {
        try unsafe path.withUnsafeCString { cString throws(Kernel.File.Open.Error) in
            try _open(unsafePath: cString, mode: mode, options: options, permissions: permissions)
        }
    }

    /// Internal implementation for opening a file using an unsafe C string pointer.
    @usableFromInline
    internal static func _open(
        unsafePath: UnsafePointer<Kernel.Path.Char>,
        mode: Kernel.File.Open.Mode,
        options: Kernel.File.Open.Options,
        permissions: Kernel.File.Permissions
    ) throws(Kernel.File.Open.Error) -> Kernel.Descriptor {
        let flags = mode.posixFlags | options.posixFlags
        let cPath = unsafe UnsafePointer<CChar>(unsafePath)

        let fd: Int32
        #if canImport(Darwin)
            if options.contains(.create) {
                fd = unsafe Darwin.open(cPath, flags, mode_t(permissions.rawValue))
            } else {
                fd = unsafe Darwin.open(cPath, flags)
            }
        #elseif canImport(Musl)
            if options.contains(.create) {
                fd = unsafe Musl.open(cPath, flags, mode_t(permissions.rawValue))
            } else {
                fd = unsafe Musl.open(cPath, flags)
            }
        #elseif canImport(Glibc)
            if options.contains(.create) {
                fd = unsafe Glibc.open(cPath, flags, mode_t(permissions.rawValue))
            } else {
                fd = unsafe Glibc.open(cPath, flags)
            }
        #endif

        guard fd >= 0 else {
            throw Kernel.File.Open.Error.current()
        }

        #if canImport(Darwin)
            if options.contains(.noCache) {
                _ = unsafe fcntl(fd, F_NOCACHE, 1)
            }
        #endif

        return Kernel.Descriptor(_rawValue: fd)
    }
}

// MARK: - Error Conversion

extension Kernel.File.Open.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let e = errno
        let code = Kernel.Error.Code.posix(e)
        if let pathError = Kernel.Path.Resolution.Error(code: code) {
            return .path(pathError)
        }
        if let permError = Kernel.Permission.Error(code: code) {
            return .permission(permError)
        }
        if let handleError = Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        if let spaceError = Kernel.Storage.Error(code: code) {
            return .space(spaceError)
        }
        if let ioError = Kernel.IO.Error(code: code) {
            return .io(ioError)
        }
        return .platform(Kernel.Error(code: code))
    }
}
