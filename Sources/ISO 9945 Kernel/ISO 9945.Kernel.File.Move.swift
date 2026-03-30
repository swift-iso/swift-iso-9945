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

// MARK: - POSIX rename() syscall

extension ISO_9945.Kernel.File.Move {
    /// Moves/renames a file or directory.
    ///
    /// - Parameters:
    ///   - oldPath: The current path.
    ///   - newPath: The new path.
    /// - Throws: `Kernel.File.Move.Error` on failure.

    @unsafe
    public static func move(
        from oldPath: UnsafePointer<Path.Char>,
        to newPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        let cOldPath = unsafe UnsafePointer<CChar>(oldPath)
        let cNewPath = unsafe UnsafePointer<CChar>(newPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.rename(cOldPath, cNewPath)
        #elseif canImport(Musl)
            let result = unsafe Musl.rename(cOldPath, cNewPath)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.rename(cOldPath, cNewPath)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }

    /// Moves/renames a file or directory using `Kernel.Path`.
    ///
    /// This is the preferred entry point.
    ///
    /// - Parameters:
    ///   - oldPath: The current path.
    ///   - newPath: The new path.
    /// - Throws: `Kernel.File.Move.Error` on failure.
    public static func move(
        from oldPath: borrowing Kernel.Path.View,
        to newPath: borrowing Kernel.Path.View
    ) throws(Error) {
        try unsafe oldPath.withUnsafePointer { (oldPtr: UnsafePointer<Path.Char>) throws(Error) in
            try unsafe newPath.withUnsafePointer { (newPtr: UnsafePointer<Path.Char>) throws(Error) in
                try unsafe move(from: oldPtr, to: newPtr)
            }
        }
    }

    /// Moves/renames a file or directory relative to directory descriptors.
    ///
    /// - Parameters:
    ///   - oldDescriptor: Directory descriptor for the old path.
    ///   - oldPath: The current path.
    ///   - newDescriptor: Directory descriptor for the new path.
    ///   - newPath: The new path.
    /// - Throws: `Kernel.File.Move.Error` on failure.

    public static func move(
        from oldDescriptor: borrowing Kernel.Descriptor,
        oldPath: UnsafePointer<Path.Char>,
        to newDescriptor: borrowing Kernel.Descriptor,
        newPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        let cOldPath = unsafe UnsafePointer<CChar>(oldPath)
        let cNewPath = unsafe UnsafePointer<CChar>(newPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.renameat(
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

extension ISO_9945.Kernel.File.Move {
    public typealias Error = Kernel.File.Move.Error
}

extension ISO_9945.Kernel.File.Move.Error {
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
