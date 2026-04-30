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


extension ISO_9945.Kernel.File {
    /// File metadata from stat/fstat syscalls.
    ///
    /// A minimal, cross-platform representation of file metadata. Platform-specific
    /// fields are normalized to common types. Use `get(path:)` or `get(descriptor:)`
    /// to retrieve stats.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Get stats by path
    /// let stats = try ISO_9945.Kernel.File.Stats.get(path: "/tmp/data.txt")
    /// print("Size: \(stats.size) bytes")
    /// print("Type: \(stats.type)")
    /// print("Permissions: \(stats.permissions)")
    ///
    /// // Get stats by descriptor
    /// let fd = try ISO_9945.Kernel.File.Open.open(path: path, mode: [.read], options: [])
    /// defer { try? ISO_9945.Kernel.Close.close(fd) }
    /// let fdStats = try ISO_9945.Kernel.File.Stats.get(descriptor: fd)
    /// ```
    ///
    /// ## Platform Notes
    ///
    /// Some fields are synthesized on Windows:
    /// - `uid`/`gid`: Always 0 (Windows doesn't have POSIX ownership)
    /// - `inode`: From file ID
    /// - `device`: From volume serial number
    /// - `changeTime`: Uses `ftLastWriteTime` (closest to POSIX ctime)
    ///
    /// For platform-specific features like birthtime/creationTime, use:
    /// - `Darwin.File.Stats.birthtime` from swift-darwin-primitives
    /// - `Windows.File.Stats.creationTime` from swift-windows-primitives
    ///
    /// ## See Also
    ///
    /// - ``Kernel/File/Stats/Kind``
    /// - ``Kernel/File/Permissions``
    public struct Stats: Sendable, Equatable {
        /// File size in bytes.
        public let size: ISO_9945.Kernel.File.Size

        /// File type (regular, directory, symlink, etc.).
        public let type: Kind

        /// POSIX file permissions (mode_t lower 12 bits).
        ///
        /// On Windows, this is synthesized from file attributes.
        public let permissions: ISO_9945.Kernel.File.Permissions

        /// Owner user ID.
        ///
        /// On Windows, this is always 0.
        public let uid: ISO_9945.Kernel.User.ID

        /// Owner group ID.
        ///
        /// On Windows, this is always 0.
        public let gid: ISO_9945.Kernel.Group.ID

        /// Inode number.
        ///
        /// On Windows, this is synthesized from file ID.
        public let inode: ISO_9945.Kernel.Inode

        /// Device ID.
        ///
        /// On Windows, this is synthesized from volume serial number.
        public let device: ISO_9945.Kernel.Device

        /// Number of hard links.
        public let linkCount: ISO_9945.Kernel.Link.Count

        /// Last access time.
        public let accessTime: ISO_9945.Kernel.Time

        /// Last modification time.
        public let modificationTime: ISO_9945.Kernel.Time

        /// Status change time (POSIX) or last write time (Windows).
        ///
        /// On POSIX, this is `st_ctime` - the time of last status change (metadata or data).
        /// On Windows, this is `ftLastWriteTime` - the closest approximation, as Windows
        /// does not track metadata changes separately.
        ///
        /// - Note: This differs from some implementations that use `ftCreationTime`.
        ///   We use `ftLastWriteTime` because it better matches POSIX ctime semantics
        ///   (it updates when the file is modified, whereas creation time never changes).
        public let changeTime: ISO_9945.Kernel.Time

        // Note: creationTime/birthtime is NOT included here because it's not available
        // on all platforms. Use platform-specific packages (swift-darwin-primitives,
        // swift-windows-primitives) for birthtime/creationTime access.

        /// Creates a Stat value.
        @inlinable
        public init(
            size: ISO_9945.Kernel.File.Size,
            type: Kind,
            permissions: ISO_9945.Kernel.File.Permissions,
            uid: ISO_9945.Kernel.User.ID,
            gid: ISO_9945.Kernel.Group.ID,
            inode: ISO_9945.Kernel.Inode,
            device: ISO_9945.Kernel.Device,
            linkCount: ISO_9945.Kernel.Link.Count,
            accessTime: ISO_9945.Kernel.Time,
            modificationTime: ISO_9945.Kernel.Time,
            changeTime: ISO_9945.Kernel.Time
        ) {
            self.size = size
            self.type = type
            self.permissions = permissions
            self.uid = uid
            self.gid = gid
            self.inode = inode
            self.device = device
            self.linkCount = linkCount
            self.accessTime = accessTime
            self.modificationTime = modificationTime
            self.changeTime = changeTime
        }
    }
}

