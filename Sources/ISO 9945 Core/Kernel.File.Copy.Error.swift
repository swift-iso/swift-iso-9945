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


extension Kernel.File.Copy {
    /// Errors that can occur during copy operations.
    ///
    /// Copy operations involve multiple syscalls (stat, clone, symlink, chmod, utimes).
    /// This error type composes the underlying Kernel errors to preserve full context.
    public enum Error: Swift.Error, Sendable, Equatable {
        // MARK: - Semantic Errors

        /// Source file does not exist.
        case sourceNotFound

        /// Destination already exists when overwrite is disabled.
        case destinationExists

        /// Source or destination is a directory.
        ///
        /// Use recursive copy for directories.
        case isDirectory

        /// Permission denied accessing source or destination.
        case permissionDenied

        // MARK: - Composed Errors

        /// Error during file clone/copy operations.
        case clone(Kernel.File.Clone.Error)

        /// Error during unlink operations.
        case unlink(Kernel.File.Delete.Error)

        /// Error during chmod operations.
        case attributes(Kernel.File.Attributes.Error)

        /// Error during utimensat operations.
        case times(Kernel.File.Times.Error)

        /// Error during mkdir operations (recursive copy).
        case mkdir(Kernel.Directory.Create.Error)

        /// Error during rmdir operations (recursive copy).
        case rmdir(Kernel.Directory.Remove.Error)

        /// Generic operation failure with a descriptive message.
        ///
        /// Used for recursive copy operations that wrap multiple errors.
        case operation(Swift.String)
    }
}

// MARK: - CustomStringConvertible

extension Kernel.File.Copy.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .sourceNotFound:
            return "source not found"
        case .destinationExists:
            return "destination already exists"
        case .isDirectory:
            return "is a directory"
        case .permissionDenied:
            return "permission denied"
        case .clone(let e):
            return "clone error: \(e)"
        case .unlink(let e):
            return "unlink error: \(e)"
        case .attributes(let e):
            return "attributes error: \(e)"
        case .times(let e):
            return "times error: \(e)"
        case .mkdir(let e):
            return "mkdir error: \(e)"
        case .rmdir(let e):
            return "rmdir error: \(e)"
        case .operation(let message):
            return "operation failed: \(message)"
        }
    }
}

// MARK: - Semantic Accessors

extension Kernel.File.Copy.Error {
    /// Returns `true` if the error indicates the source was not found.
    public var isSourceNotFound: Bool {
        if case .sourceNotFound = self { return true }
        return false
    }

    /// Returns `true` if the error indicates the destination already exists.
    public var isDestinationExists: Bool {
        if case .destinationExists = self { return true }
        return false
    }

    /// Returns `true` if the error indicates a directory was encountered.
    public var isDirectory: Bool {
        if case .isDirectory = self { return true }
        return false
    }

    /// Returns `true` if the error indicates permission was denied.
    public var isPermissionDenied: Bool {
        if case .permissionDenied = self { return true }
        return false
    }
}

