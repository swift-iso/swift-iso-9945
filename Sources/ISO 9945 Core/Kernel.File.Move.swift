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


extension ISO_9945.Kernel.File {
    /// File and directory move operations.
    ///
    /// Moves (renames) files and directories atomically within the same
    /// filesystem. Cross-filesystem moves require copy-and-delete.
    ///
    /// Wraps POSIX `rename()` / Windows `MoveFileExW()`.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-posix-primitives` (`Posix.Kernel.File.Move`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.File.Move`)
    public enum Move: Sendable {}
}

// MARK: - Error

extension ISO_9945.Kernel.File.Move {
    /// Errors that can occur during file move operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The source path does not exist.
        case notFound

        /// Permission denied.
        case permission

        /// Source and destination are on different filesystems.
        case crossDevice

        /// The destination is a non-empty directory.
        case notEmpty

        /// A path component is not a directory.
        case notDirectory

        /// Attempting to move a directory to a subdirectory of itself.
        case invalidArgument

        /// The source is a directory but destination is a file.
        case isDirectory

        /// The filesystem is read-only.
        case readOnly

        /// Too many symbolic links encountered.
        case loop

        /// Path name is too long.
        case nameTooLong

        /// Not enough space.
        case noSpace

        /// A platform-specific error.
        case platform(Error_Primitives.Error)
    }
}

extension ISO_9945.Kernel.File.Move.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "source path not found"
        case .permission: return "permission denied"
        case .crossDevice: return "cross-device move not supported"
        case .notEmpty: return "destination directory not empty"
        case .notDirectory: return "path component is not a directory"
        case .invalidArgument: return "invalid argument"
        case .isDirectory: return "cannot overwrite directory with file"
        case .readOnly: return "read-only filesystem"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .noSpace: return "no space left on device"
        case .platform(let e): return "\(e)"
        }
    }
}

