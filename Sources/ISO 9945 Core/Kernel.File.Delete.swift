// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


extension Kernel.File {
    /// File deletion operations.
    ///
    /// Removes directory entries (file names) from the filesystem. On POSIX,
    /// the underlying data is freed when the last link is removed and no
    /// processes have the file open. On Windows, deletion may be delayed
    /// until all handles are closed.
    ///
    /// Wraps POSIX `unlink()` / Windows `DeleteFileW()`.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-posix-primitives` (`Posix.Kernel.File.Delete`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.File.Delete`)
    ///
    /// - Note: To remove directories, use ``Kernel/Directory/Remove``.
    public enum Delete: Sendable {}
}

// MARK: - Error

extension Kernel.File.Delete {
    /// Errors that can occur during file deletion.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The file does not exist.
        case notFound

        /// Permission denied.
        case permission

        /// The path refers to a directory.
        case isDirectory

        /// A component of the path is not a directory.
        case notDirectory

        /// The filesystem is read-only.
        case readOnly

        /// The file is busy (executable running, etc.).
        case busy

        /// Too many symbolic links encountered.
        case loop

        /// Path name is too long.
        case nameTooLong

        /// A platform-specific error.
        case platform(Error_Primitives.Error)
    }
}

extension Kernel.File.Delete.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "file not found"
        case .permission: return "permission denied"
        case .isDirectory: return "is a directory"
        case .notDirectory: return "path component is not a directory"
        case .readOnly: return "read-only filesystem"
        case .busy: return "file busy"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .platform(let e): return "\(e)"
        }
    }
}

