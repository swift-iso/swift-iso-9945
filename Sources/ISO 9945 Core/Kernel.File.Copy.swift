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
/// - Efficient data copying via `ISO_9945.Kernel.File.Clone`
/// - Attribute preservation (permissions, timestamps)
///
/// ## Usage
///
/// ```swift
/// // Copy with default options
/// try ISO_9945.Kernel.File.Copy.copy(from: sourcePath, to: destinationPath)
///
/// // Copy with options
/// try ISO_9945.Kernel.File.Copy.copy(
///     from: sourcePath,
///     to: destinationPath,
///     options: .init(overwrite: true, copyAttributes: true)
/// )
/// ```
///
/// ## Platform Implementation
///
/// Copy operations use cross-platform Kernel APIs:
/// - `ISO_9945.Kernel.File.Stats` for metadata
/// - `ISO_9945.Kernel.File.Clone` for data copying
/// - `ISO_9945.Kernel.Link.Symbolic` for symlink handling
/// - `ISO_9945.Kernel.File.Attributes` for permissions
/// - `ISO_9945.Kernel.File.Times` for timestamps
extension ISO_9945.Kernel.File {
    public enum Copy {}
}
