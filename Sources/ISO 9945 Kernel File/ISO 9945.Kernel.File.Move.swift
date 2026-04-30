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

    /// Moves/renames a file or directory using `Path`.
    ///
    /// This is the preferred entry point.
    ///
    /// - Parameters:
    ///   - oldPath: The current path.
    ///   - newPath: The new path.
    /// - Throws: `Kernel.File.Move.Error` on failure.
    public static func move(
        from oldPath: borrowing Path.Borrowed,
        to newPath: borrowing Path.Borrowed
    ) throws(Error) {
        try unsafe oldPath.withUnsafePointer { (oldPtr: UnsafePointer<Path.Char>) throws(Error) in
            try unsafe newPath.withUnsafePointer { (newPtr: UnsafePointer<Path.Char>) throws(Error) in
                try unsafe move(from: oldPtr, to: newPtr)
            }
        }
    }
}

// MARK: - POSIX renameat() syscall (raw @_spi(Syscall))

extension ISO_9945.Kernel.File.Move {
    /// Moves/renames a file or directory relative to raw directory descriptors.
    ///
    /// Spec-literal raw `renameat(2)`. The typed L2 convenience
    /// (`ISO_9945.Kernel.File.Move.move(from:oldPath:to:newPath:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameters:
    ///   - oldFd: Raw directory descriptor for the old path.
    ///   - oldPath: The current path.
    ///   - newFd: Raw directory descriptor for the new path.
    ///   - newPath: The new path.
    /// - Throws: `Kernel.File.Move.Error` on failure.
    @_spi(Syscall)
    public static func move(
        from oldFd: Int32,
        oldPath: UnsafePointer<Path.Char>,
        to newFd: Int32,
        newPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        let cOldPath = unsafe UnsafePointer<CChar>(oldPath)
        let cNewPath = unsafe UnsafePointer<CChar>(newPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.renameat(oldFd, cOldPath, newFd, cNewPath)
        #elseif canImport(Musl)
            let result = unsafe Musl.renameat(oldFd, cOldPath, newFd, cNewPath)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.renameat(oldFd, cOldPath, newFd, cNewPath)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

// MARK: - Typed Convenience

extension ISO_9945.Kernel.File.Move {
    /// Moves/renames a file or directory relative to directory descriptors.
    ///
    /// Typed L2 form. Delegates to the raw `move(from:oldPath:to:newPath:)`
    /// SPI via `descriptor._rawValue`.
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
        try unsafe move(
            from: oldDescriptor._rawValue,
            oldPath: oldPath,
            to: newDescriptor._rawValue,
            newPath: newPath
        )
    }
}

// MARK: - Error

extension ISO_9945.Kernel.File.Move {
    public typealias Error = Kernel.File.Move.Error
}

extension ISO_9945.Kernel.File.Move.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
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
            return .platform(Error_Primitives.Error(code: code))
        }
    }
}
