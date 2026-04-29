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


/// Namespace for high-level file copy operations.
///
/// Provides a complete file copy operation that handles:
/// - Source validation (exists, not a directory)
/// - Destination handling (overwrite or fail)
/// - Symbolic link preservation
/// - Efficient data copying via `Kernel.File.Clone`
/// - Attribute preservation (permissions, timestamps)
///
/// ## Usage
///
/// ```swift
/// // Copy with default options
/// try Kernel.File.Copy.copy(from: sourcePath, to: destinationPath)
///
/// // Copy with options
/// try Kernel.File.Copy.copy(
///     from: sourcePath,
///     to: destinationPath,
///     options: .init(overwrite: true, copyAttributes: true)
/// )
/// ```
///
/// ## Platform Implementation
///
/// Copy operations use cross-platform Kernel APIs:
/// - `Kernel.File.Stats` for metadata
/// - `Kernel.File.Clone` for data copying
/// - `Kernel.Link.Symbolic` for symlink handling
/// - `Kernel.File.Attributes` for permissions
/// - `Kernel.File.Times` for timestamps
extension Kernel.File {
    public enum Copy {}
}

