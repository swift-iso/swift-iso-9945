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

extension ISO_9945.Kernel.File {
    /// Change file ownership.
    ///
    /// Provides cross-platform file ownership modification.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.File.Chown`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.File.Chown`)
    public enum Chown {}
}

// MARK: - Error

extension ISO_9945.Kernel.File.Chown {
    /// Errors that can occur during chown operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The path does not exist.
        case path(Path)

        /// Permission errors.
        case permission(Permission)

        /// I/O errors.
        case io(IO)

        /// Platform-specific error.
        case platform(Error_Primitives.Error)
    }
}

extension ISO_9945.Kernel.File.Chown.Error {
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

extension ISO_9945.Kernel.File.Chown.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .path(let pathError):
            return "chown path error: \(pathError)"
        case .permission(let permError):
            return "chown permission error: \(permError)"
        case .io(let ioError):
            return "chown I/O error: \(ioError)"
        case .platform(let e):
            return "chown error: \(e)"
        }
    }
}
