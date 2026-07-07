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
    /// Directory creation operations.
    ///
    /// Creates directories in the filesystem. On POSIX, directories are created
    /// with the specified permissions (modified by umask). On Windows, default
    /// security attributes are used.
    ///
    /// Wraps POSIX `mkdir()` / Windows `CreateDirectoryW()`.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-posix-primitives` (`Posix.Kernel.Directory.Create`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.Directory.Create`)
    public enum Create: Sendable {}
}

// MARK: - Error

extension ISO_9945.Kernel.Directory.Create {
    /// Errors that can occur during directory creation.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// A component of the path does not exist.
        case notFound

        /// Permission denied.
        case permission

        /// The path already exists.
        case exists

        /// A component of the path is not a directory.
        case notDirectory

        /// The filesystem is read-only.
        case readOnly

        /// Not enough space to create the directory.
        case noSpace

        /// Too many symbolic links encountered.
        case loop

        /// Path name is too long.
        case nameTooLong

        /// A platform-specific error.
        case platform(Error_Primitives.Error)
    }
}

extension ISO_9945.Kernel.Directory.Create.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "path component not found"
        case .permission: return "permission denied"
        case .exists: return "path already exists"
        case .notDirectory: return "path component is not a directory"
        case .readOnly: return "read-only filesystem"
        case .noSpace: return "no space left on device"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .platform(let e): return "\(e)"
        }
    }
}
