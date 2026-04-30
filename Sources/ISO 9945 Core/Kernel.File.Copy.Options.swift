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


extension ISO_9945.Kernel.File.Copy {
    /// Options for copy operations.
    public struct Options: Sendable, Equatable {
        /// Overwrite existing destination file.
        ///
        /// When `false` (default), throws `.destinationExists` if the
        /// destination already exists.
        public var overwrite: Bool

        /// Copy file attributes (permissions, timestamps).
        ///
        /// When `true` (default), copies owner permissions and
        /// access/modification timestamps from source to destination.
        public var copyAttributes: Bool

        /// Follow symbolic links.
        ///
        /// When `true` (default), copies the target of symbolic links.
        /// When `false`, recreates the symbolic link at the destination.
        public var followSymlinks: Bool

        /// Creates copy options with the specified settings.
        ///
        /// - Parameters:
        ///   - overwrite: Overwrite existing destination. Default: `false`.
        ///   - copyAttributes: Copy permissions and timestamps. Default: `true`.
        ///   - followSymlinks: Follow symlinks (copy target). Default: `true`.
        public init(
            overwrite: Bool = false,
            copyAttributes: Bool = true,
            followSymlinks: Bool = true
        ) {
            self.overwrite = overwrite
            self.copyAttributes = copyAttributes
            self.followSymlinks = followSymlinks
        }
    }
}

