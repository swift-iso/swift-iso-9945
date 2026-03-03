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
    /// Zero-allocation file open using borrowed path view.
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
    /// - ``Error/path(_:)``: Path does not exist, is invalid, or resolution failed
    /// - ``Error/permission(_:)``: Insufficient permissions for requested mode
    /// - ``Error/handle(_:)``: Process or system descriptor limit reached
    /// - ``Error/space(_:)``: No space for file creation
    /// - ``Error/io(_:)``: I/O error during open
    ///
    /// - Parameters:
    ///   - path: The file path to open (borrowed, zero-copy).
    ///   - mode: Read/write access mode (.read, .write, or .readWrite).
    ///   - options: Creation and behavior options (.create, .truncate, etc.).
    ///   - permissions: POSIX permissions for newly created files.
    /// - Returns: A file descriptor for the opened file.
    /// - Throws: ``Kernel/File/Open/Error`` on failure.
    /// - Complexity: O(1) in Swift, O(path length) in kernel.
    public static func open(
        path: borrowing Kernel.Path.View,
        mode: Kernel.File.Open.Mode,
        options: Kernel.File.Open.Options,
        permissions: Kernel.File.Permissions
    ) throws(Kernel.File.Open.Error) -> Kernel.Descriptor {
        try unsafe path.withUnsafePointer { cString throws(Kernel.File.Open.Error) in
            try _open(unsafePath: cString, mode: mode, options: options, permissions: permissions)
        }
    }

    /// Internal implementation using unsafe C string pointer.
    @usableFromInline
    internal static func _open(
        unsafePath: UnsafePointer<Path.Char>,
        mode: Kernel.File.Open.Mode,
        options: Kernel.File.Open.Options,
        permissions: Kernel.File.Permissions
    ) throws(Kernel.File.Open.Error) -> Kernel.Descriptor {
        let cPath = unsafe UnsafePointer<CChar>(unsafePath)

        // Convert Mode to POSIX access flags at syscall boundary
        let accessMode: Int32 = switch (mode.read, mode.write) {
        case (true, false):  O_RDONLY
        case (false, true):  O_WRONLY
        case (true, true):   O_RDWR
        case (false, false): O_RDONLY
        }

        #if canImport(Darwin)
            // Darwin: exclude internal noCache flag from open(), apply via fcntl after
            let flags = accessMode | options.openFlags

            let fd = unsafe Darwin.open(cPath, flags, mode_t(permissions.rawValue))
            guard fd >= 0 else {
                throw Kernel.File.Open.Error.current()
            }

            // Apply F_NOCACHE if requested
            if options.needsNoCache {
                _ = unsafe fcntl(fd, F_NOCACHE, 1)
            }
        #elseif canImport(Musl)
            let flags = accessMode | options.rawValue
            let fd = unsafe Musl.open(cPath, flags, mode_t(permissions.rawValue))
            guard fd >= 0 else {
                throw Kernel.File.Open.Error.current()
            }
        #elseif canImport(Glibc)
            let flags = accessMode | options.rawValue
            let fd = unsafe Glibc.open(cPath, flags, mode_t(permissions.rawValue))
            guard fd >= 0 else {
                throw Kernel.File.Open.Error.current()
            }
        #endif

        return Kernel.Descriptor(_rawValue: fd)
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.File.Open.Error {
    /// Creates an error from the current errno value.
    @usableFromInline
    internal static func current() -> Self {
        Self(code: .posix(errno))
    }
}
