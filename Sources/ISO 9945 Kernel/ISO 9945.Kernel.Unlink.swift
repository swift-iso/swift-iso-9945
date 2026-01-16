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

// MARK: - POSIX unlink() syscall

extension ISO_9945.Kernel.Unlink {
    /// Removes a file or symbolic link.
    ///
    /// - Parameter path: The path to the file to remove.
    /// - Throws: `Kernel.Unlink.Error` on failure.
    public static func unlink(_ path: borrowing Kernel.Path) throws(Error) {
        try unlink(path.unsafeCString)
    }

    /// Removes a file or symbolic link using an unsafe path pointer.
    ///
    /// - Parameter path: The path to the file to remove.
    /// - Throws: `Kernel.Unlink.Error` on failure.

    public static func unlink(_ path: UnsafePointer<Kernel.Path.Char>) throws(Error) {
        let cPath = unsafe UnsafeRawPointer(path).assumingMemoryBound(to: CChar.self)

        #if canImport(Darwin)
            let result = Darwin.unlink(cPath)
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
    ///   - flags: Flags to control the operation (e.g., AT_REMOVEDIR).
    /// - Throws: `Kernel.Unlink.Error` on failure.

    public static func unlinkat(
        _ descriptor: Kernel.Descriptor,
        path: UnsafePointer<Kernel.Path.Char>,
        flags: Int32 = 0
    ) throws(Error) {
        let cPath = unsafe UnsafeRawPointer(path).assumingMemoryBound(to: CChar.self)

        #if canImport(Darwin)
            let result = Darwin.unlinkat(descriptor._rawValue, cPath, flags)
        #elseif canImport(Musl)
            let result = Musl.unlinkat(descriptor._rawValue, cPath, flags)
        #elseif canImport(Glibc)
            let result = Glibc.unlinkat(descriptor._rawValue, cPath, flags)
        #endif

        try Kernel.Syscall.require(result, .equals(0), orThrow: Error.current())
    }
}

// MARK: - Error

extension ISO_9945.Kernel.Unlink {
    public typealias Error = Kernel.Unlink.Error
}

extension Kernel.Unlink.Error {
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
