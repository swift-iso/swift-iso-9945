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

// MARK: - File Open Mode

extension ISO_9945.Kernel.File.Open {
    /// File access mode specifying read and/or write permissions.
    ///
    /// A simple struct with two boolean flags indicating the desired access.
    /// Use the static conveniences for common cases.
    ///
    /// ## Usage
    /// ```swift
    /// // Read only
    /// let fd = try ISO_9945.Kernel.File.Open.open(path: view, mode: .read, ...)
    ///
    /// // Write only
    /// let fd = try ISO_9945.Kernel.File.Open.open(path: view, mode: .write, ...)
    ///
    /// // Read and write
    /// let fd = try ISO_9945.Kernel.File.Open.open(path: view, mode: .readWrite, ...)
    ///
    /// // Explicit construction
    /// let fd = try ISO_9945.Kernel.File.Open.open(path: view, mode: Mode(read: true, write: true), ...)
    /// ```
    public struct Mode: Sendable, Hashable {
        /// Whether to open the file for reading.
        public let read: Bool

        /// Whether to open the file for writing.
        public let write: Bool

        /// Creates a mode with explicit read/write permissions.
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

// MARK: - Standard Modes

extension ISO_9945.Kernel.File.Open.Mode {
    /// Opens the file for reading only.
    public static let read = Self(read: true, write: false)

    /// Opens the file for writing only.
    public static let write = Self(read: false, write: true)

    /// Opens the file for reading and writing.
    public static let readWrite = Self(read: true, write: true)
}
