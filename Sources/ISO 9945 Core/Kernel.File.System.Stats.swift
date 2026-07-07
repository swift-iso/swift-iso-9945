// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.File.System {
    /// Filesystem statistics.
    ///
    /// Used by higher layers (swift-io) for Direct I/O capability probing
    /// and filesystem type detection.
    ///
    /// ## Platform Differences
    ///
    /// The `type` field has different semantics across platforms:
    /// - **POSIX**: Filesystem magic number (e.g., 0x9123683E for Btrfs, 0x58465342 for XFS).
    ///   Use this to detect filesystem capabilities.
    /// - **Windows**: Volume serial number, which identifies a specific volume instance.
    ///   Use `fsTypeName` (e.g., "NTFS", "FAT32") for filesystem type detection on Windows.
    ///
    /// For cross-platform filesystem type detection, prefer `fsTypeName` when available,
    /// falling back to `type` magic number comparison on POSIX systems.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.File.System.Stats`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.File.System.Stats`)
    public struct Stats: Sendable, Equatable, Hashable {
        /// Filesystem type identifier.
        ///
        /// - POSIX: `f_type` — Filesystem magic number (e.g., 0x9123683E for Btrfs).
        ///   These values are platform-specific and can be used to detect filesystem capabilities.
        /// - Windows: Volume serial number, which identifies the volume instance.
        ///   **Note**: This is NOT a filesystem type. Use `fsTypeName` for type detection on Windows.
        ///
        /// - Important: The semantic meaning differs between platforms. For portable
        ///   filesystem type detection, use `fsTypeName` when available.
        public let type: ISO_9945.Kernel.File.System.Kind

        /// Optimal transfer block size in bytes.
        public let blockSize: ISO_9945.Kernel.File.System.Block.Size

        /// Total data blocks in filesystem.
        public let blocks: ISO_9945.Kernel.File.System.Block.Count

        /// Free blocks in filesystem.
        public let freeBlocks: ISO_9945.Kernel.File.System.Block.Count

        /// Free blocks available to unprivileged user.
        public let availableBlocks: ISO_9945.Kernel.File.System.Block.Count

        /// Total file nodes (inodes) in filesystem.
        public let files: ISO_9945.Kernel.File.System.File.Count

        /// Free file nodes in filesystem.
        public let freeFiles: ISO_9945.Kernel.File.System.File.Count

        /// Filesystem ID.
        public let fsid: ISO_9945.Kernel.File.System.ID

        /// Maximum length of filenames.
        public let nameMax: ISO_9945.Kernel.File.System.Name.Length

        /// Filesystem type name.
        ///
        /// - Darwin: `f_fstypename` (e.g., "apfs", "hfs", "nfs")
        /// - Linux: Not available (derived from `type` if needed)
        /// - Windows: Filesystem name from `GetVolumeInformationW` (e.g., "NTFS", "FAT32")
        ///
        /// This field is `nil` when the filesystem type name is not available.
        public let fsTypeName: Swift.String?

        /// Creates filesystem statistics with the given values.
        public init(
            type: ISO_9945.Kernel.File.System.Kind,
            blockSize: ISO_9945.Kernel.File.System.Block.Size,
            blocks: ISO_9945.Kernel.File.System.Block.Count,
            freeBlocks: ISO_9945.Kernel.File.System.Block.Count,
            availableBlocks: ISO_9945.Kernel.File.System.Block.Count,
            files: ISO_9945.Kernel.File.System.File.Count,
            freeFiles: ISO_9945.Kernel.File.System.File.Count,
            fsid: ISO_9945.Kernel.File.System.ID,
            nameMax: ISO_9945.Kernel.File.System.Name.Length,
            fsTypeName: Swift.String? = nil
        ) {
            self.type = type
            self.blockSize = blockSize
            self.blocks = blocks
            self.freeBlocks = freeBlocks
            self.availableBlocks = availableBlocks
            self.files = files
            self.freeFiles = freeFiles
            self.fsid = fsid
            self.nameMax = nameMax
            self.fsTypeName = fsTypeName
        }
    }
}
