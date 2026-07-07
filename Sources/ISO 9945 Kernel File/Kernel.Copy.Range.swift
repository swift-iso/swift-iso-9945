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

extension ISO_9945.Kernel.Copy {
    /// Range-based copy operations.
    ///
    /// Enables efficient kernel-space copying between file descriptors,
    /// potentially using server-side copy for network filesystems.
    ///
    /// ## Platform Support
    ///
    /// | Platform | Mechanism | Implementation Package |
    /// |----------|-----------|------------------------|
    /// | Linux | `copy_file_range(2)` | `swift-iso-9945` |
    ///
    /// ## Platform Implementation
    ///
    /// Range copy operations are in platform-specific packages:
    /// - Linux: `swift-iso-9945` (`ISO_9945.Kernel.Copy.Range.copy`)
    public enum Range {}
}
