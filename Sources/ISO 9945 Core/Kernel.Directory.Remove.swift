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

extension ISO_9945.Kernel.Directory {
    /// Directory removal operations.
    ///
    /// Removes empty directories from the filesystem.
    ///
    /// Wraps POSIX `rmdir()` / Windows `RemoveDirectoryW()`.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-posix-primitives` (`Posix.Kernel.Directory.Remove`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.Directory.Remove`)
    ///
    /// - Note: To remove files, use ``Kernel/File/Delete``. To remove non-empty
    ///   directories, you must first remove all contents recursively.
    public enum Remove: Sendable {}
}

// MARK: - Error

extension ISO_9945.Kernel.Directory.Remove {
    /// Errors that can occur during directory removal.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The directory does not exist.
        case notFound

        /// Permission denied.
        case permission

        /// The directory is not empty.
        case notEmpty

        /// The path is not a directory.
        case notDirectory

        /// The directory is busy (e.g., mount point or current directory).
        case busy

        /// The filesystem is read-only.
        case readOnly

        /// Too many symbolic links encountered.
        case loop

        /// Path name is too long.
        case nameTooLong

        /// A platform-specific error.
        case platform(Error_Primitives.Error)
    }
}

extension ISO_9945.Kernel.Directory.Remove.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "directory not found"
        case .permission: return "permission denied"
        case .notEmpty: return "directory not empty"
        case .notDirectory: return "not a directory"
        case .busy: return "directory busy"
        case .readOnly: return "read-only filesystem"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .platform(let e): return "\(e)"
        }
    }
}
