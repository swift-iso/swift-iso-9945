// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-kernel-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


extension ISO_9945.Kernel.File.Open {
    /// File access mode for open operations.
    ///
    /// Specifies whether a file descriptor is opened for reading, writing,
    /// or both. These three modes are standardized by POSIX and universal
    /// across all platforms.
    ///
    /// ## Platform Implementation
    ///
    /// Platform packages extend this type with additional functionality:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.File.Open.Access`)
    /// - Linux: `swift-linux-primitives` (`Linux.Kernel.File.Open.Access`)
    /// - Darwin: `swift-darwin-primitives` (`Darwin.Kernel.File.Open.Access`)
    public enum Access: Sendable, Hashable {
        /// Read-only access (O_RDONLY).
        case readOnly
        /// Write-only access (O_WRONLY).
        case writeOnly
        /// Read-write access (O_RDWR).
        case readWrite

        /// The POSIX raw value for this access mode.
        ///
        /// These values are standardized by POSIX and identical across
        /// all conforming platforms:
        /// - `readOnly`: 0 (O_RDONLY)
        /// - `writeOnly`: 1 (O_WRONLY)
        /// - `readWrite`: 2 (O_RDWR)
        @inlinable
        public var rawValue: Int32 {
            switch self {
            case .readOnly: 0
            case .writeOnly: 1
            case .readWrite: 2
            }
        }
    }
}

