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


extension Kernel.Directory {
    /// Errors that can occur during directory operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The directory does not exist.
        case notFound

        /// Permission denied.
        case permission

        /// The path is not a directory.
        case notDirectory

        /// Too many open files.
        case tooManyOpenFiles

        /// An I/O error occurred.
        case io

        /// A platform-specific error.
        case platform(Error_Primitives.Error)
    }
}

extension Kernel.Directory.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notFound: return "directory not found"
        case .permission: return "permission denied"
        case .notDirectory: return "not a directory"
        case .tooManyOpenFiles: return "too many open files"
        case .io: return "I/O error"
        case .platform(let e): return "\(e)"
        }
    }
}

