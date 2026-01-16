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

// MARK: - POSIX rename() syscall

extension ISO_9945.Kernel.Rename {
    /// Renames a file or directory.
    ///
    /// - Parameters:
    ///   - oldPath: The current path.
    ///   - newPath: The new path.
    /// - Throws: `Kernel.Rename.Error` on failure.

    public static func rename(
        from oldPath: UnsafePointer<Kernel.Path.Char>,
        to newPath: UnsafePointer<Kernel.Path.Char>
    ) throws(Error) {
        let cOldPath = unsafe UnsafeRawPointer(oldPath).assumingMemoryBound(to: CChar.self)
        let cNewPath = unsafe UnsafeRawPointer(newPath).assumingMemoryBound(to: CChar.self)

        #if canImport(Darwin)
            let result = Darwin.rename(cOldPath, cNewPath)
        #elseif canImport(Musl)
            let result = Musl.rename(cOldPath, cNewPath)
        #elseif canImport(Glibc)
            let result = Glibc.rename(cOldPath, cNewPath)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }

    /// Renames a file or directory relative to directory descriptors.
    ///
    /// - Parameters:
    ///   - oldDescriptor: Directory descriptor for the old path.
    ///   - oldPath: The current path.
    ///   - newDescriptor: Directory descriptor for the new path.
    ///   - newPath: The new path.
    /// - Throws: `Kernel.Rename.Error` on failure.

    public static func renameat(
        _ oldDescriptor: Kernel.Descriptor,
        oldPath: UnsafePointer<Kernel.Path.Char>,
        _ newDescriptor: Kernel.Descriptor,
        newPath: UnsafePointer<Kernel.Path.Char>
    ) throws(Error) {
        let cOldPath = unsafe UnsafeRawPointer(oldPath).assumingMemoryBound(to: CChar.self)
        let cNewPath = unsafe UnsafeRawPointer(newPath).assumingMemoryBound(to: CChar.self)

        #if canImport(Darwin)
            let result = Darwin.renameat(
                oldDescriptor._rawValue, cOldPath,
                newDescriptor._rawValue, cNewPath
            )
        #elseif canImport(Musl)
            let result = Musl.renameat(
                oldDescriptor._rawValue, cOldPath,
                newDescriptor._rawValue, cNewPath
            )
        #elseif canImport(Glibc)
            let result = Glibc.renameat(
                oldDescriptor._rawValue, cOldPath,
                newDescriptor._rawValue, cNewPath
            )
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

// MARK: - Error

extension ISO_9945.Kernel.Rename {
    public typealias Error = Kernel.Rename.Error
}

extension Kernel.Rename.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Kernel.Error.Code.current()
        switch code {
        case .ENOENT:
            return .notFound
        case .EACCES, .EPERM:
            return .permission
        case .EXDEV:
            return .crossDevice
        case .ENOTEMPTY:
            return .notEmpty
        case .ENOTDIR:
            return .notDirectory
        case .EINVAL:
            return .invalidArgument
        case .EISDIR:
            return .isDirectory
        case .EROFS:
            return .readOnly
        case .ELOOP:
            return .loop
        case .ENAMETOOLONG:
            return .nameTooLong
        case .ENOSPC:
            return .noSpace
        default:
            return .platform(Kernel.Error(code: code))
        }
    }
}
