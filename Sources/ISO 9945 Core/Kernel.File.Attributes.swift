// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


extension Kernel.File {
    /// File attributes operations.
    ///
    /// Provides cross-platform file permission/attributes modification.
    ///
    /// Wraps POSIX `chmod()` / Windows `SetFileAttributesW()`.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-posix-primitives` (`Posix.Kernel.File.Attributes`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.File.Attributes`)
    public enum Attributes {}
}

// MARK: - Error

extension Kernel.File.Attributes {
    /// Errors that can occur during file attributes operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The path does not exist.
        case path(Path)

        /// Permission errors.
        case permission(Permission)

        /// I/O errors.
        case io(IO)

        /// Platform-specific error.
        case platform(Error_Primitives.Error)

        // Path-related errors
        public enum Path: Swift.Error, Sendable, Equatable {
            case notFound
            case tooLong
            case loop
        }

        // Permission-related errors
        public enum Permission: Swift.Error, Sendable, Equatable {
            case denied
            case notPermitted
            case readOnlyFilesystem
        }

        // I/O errors
        public enum IO: Swift.Error, Sendable, Equatable {
            case hardware
        }
    }
}

extension Kernel.File.Attributes.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .path(let pathError):
            return "file attributes path error: \(pathError)"
        case .permission(let permError):
            return "file attributes permission error: \(permError)"
        case .io(let ioError):
            return "file attributes I/O error: \(ioError)"
        case .platform(let e):
            return "file attributes error: \(e)"
        }
    }
}

