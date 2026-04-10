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

// MARK: - Shared Memory Access Mode

extension ISO_9945.Kernel.Memory.Shared {
    /// Access mode for shared memory objects.
    ///
    /// A simple struct with two boolean flags indicating the desired access.
    /// Use the static conveniences for common cases.
    ///
    /// ## Usage
    /// ```swift
    /// // Read only
    /// let fd = try Kernel.Memory.Shared.open(name: "/myshm", access: .read, ...)
    ///
    /// // Write only
    /// let fd = try Kernel.Memory.Shared.open(name: "/myshm", access: .write, ...)
    ///
    /// // Read and write
    /// let fd = try Kernel.Memory.Shared.open(name: "/myshm", access: .readWrite, ...)
    /// ```
    public struct Access: Sendable, Hashable {
        /// Whether to open for reading.
        public let read: Bool

        /// Whether to open for writing.
        public let write: Bool

        /// Creates an access mode with explicit read/write permissions.
        ///
        /// - Parameters:
        ///   - read: Whether to open for reading.
        ///   - write: Whether to open for writing.
        @inlinable
        public init(read: Bool, write: Bool) {
            self.read = read
            self.write = write
        }
    }
}

// MARK: - Standard Access Modes

extension ISO_9945.Kernel.Memory.Shared.Access {
    /// Opens the shared memory for reading only.
    public static let read = Self(read: true, write: false)

    /// Opens the shared memory for writing only.
    public static let write = Self(read: false, write: true)

    /// Opens the shared memory for reading and writing.
    public static let readWrite = Self(read: true, write: true)
}
