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

internal import Cardinal_Primitives

extension ISO_9945.Kernel.File.System {
    /// Filesystem block types.
    public enum Block {}
}

// MARK: - Block.Size

extension ISO_9945.Kernel.File.System.Block {
    /// Filesystem block size.
    ///
    /// A type-safe size value using the Dimension pattern.
    /// Follows the same pattern as `ISO_9945.Kernel.File.Size`.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let stats = try ISO_9945.Kernel.File.System.Stats.get(path)
    /// let totalBytes = stats.blocks.rawValue * stats.blockSize.rawValue
    /// ```
    public typealias Size = Magnitude<ISO_9945.Kernel.File.System.Block>.Value<UInt64>
}

// MARK: - Block.Size Constants

extension ISO_9945.Kernel.File.System.Block.Size {
    /// 512-byte sector (traditional disk sector).
    public static let sector512: Self = Self(512)

    /// 4096-byte page (common filesystem block size).
    public static let page4096: Self = Self(4096)
}

// MARK: - Block.Count

extension ISO_9945.Kernel.File.System.Block {
    /// Block count for filesystem statistics.
    ///
    /// A type-safe wrapper for filesystem block counts (total, free, available).
    /// Multiply by the block size to get the size in bytes.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let stats = try ISO_9945.Kernel.File.System.Stats.get(path)
    /// let freeBytes = stats.freeBlocks.rawValue * stats.blockSize.rawValue
    /// ```
    public typealias Count = Tagged<ISO_9945.Kernel.File.System.Block, Cardinal>
}
