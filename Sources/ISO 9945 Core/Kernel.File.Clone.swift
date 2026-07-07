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

/// Namespace for file cloning (copy-on-write reflink) operations.
///
/// File cloning creates a lightweight copy that shares storage with the original
/// until either file is modified. This is significantly faster than a byte-by-byte
/// copy for large files on supported filesystems.
///
/// ## Platform Support
///
/// | Platform | Filesystem | Mechanism |
/// |----------|------------|-----------|
/// | macOS | APFS | `clonefile()` |
/// | Linux | Btrfs, XFS | `ioctl(FICLONE)` |
/// | Linux | Any | `copy_file_range()` (may CoW) |
/// | Windows | ReFS | `FSCTL_DUPLICATE_EXTENTS_TO_FILE` |
///
/// ## Usage
///
/// ```swift
/// // Clone with fallback to copy
/// try ISO_9945.Kernel.File.Clone.clone(
///     from: sourcePath,
///     to: destinationPath,
///     behavior: .reflinkOrCopy
/// )
///
/// // Probe capability first
/// let cap = try ISO_9945.Kernel.File.Clone.capability(at: sourcePath)
/// if cap == .reflink {
///     try ISO_9945.Kernel.File.Clone.clone(from: sourcePath, to: destinationPath, behavior: .reflinkOrFail)
/// }
/// ```
///
/// ## Platform Implementation
///
/// Clone operations are in platform-specific packages:
/// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.File.Clone`)
/// - Windows: `swift-windows-primitives` (`Windows.Kernel.File.Clone`)
extension ISO_9945.Kernel.File {
    public enum Clone {}
}

// MARK: - Capability Probing

extension ISO_9945.Kernel.File.Clone.Capability {
    /// Probes whether the filesystem at the given path supports cloning.
    ///
    /// ## Platform Implementation
    ///
    /// Capability probing is in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.File.Clone.Capability.probe`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.File.Clone.Capability.probe`)
    ///
    /// Returns `.none` by default. Use platform packages for actual probing.
    public static func probeDefault(at path: borrowing Path) -> ISO_9945.Kernel.File.Clone.Capability {
        _ = path
        return .none
    }
}

// MARK: - File Metadata

extension ISO_9945.Kernel.File.Clone {
    /// File metadata operations.
    ///
    /// ## Platform Implementation
    ///
    /// Metadata operations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.File.Clone.Metadata`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.File.Clone.Metadata`)
    public enum Metadata {}
}
