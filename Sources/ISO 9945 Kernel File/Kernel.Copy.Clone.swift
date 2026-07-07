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
    /// Clone operations (copy-on-write).
    ///
    /// Creates copy-on-write clones where supported, sharing data blocks
    /// until either file is modified.
    ///
    /// ## Platform Support
    ///
    /// | Platform | Mechanism | Implementation Package |
    /// |----------|-----------|------------------------|
    /// | Linux | `FICLONE` ioctl | `swift-iso-9945` |
    /// | macOS | `clonefile()` | `swift-iso-9945` |
    /// | Windows | Block cloning | `swift-windows-primitives` |
    ///
    /// ## Platform Implementation
    ///
    /// Clone operations are in platform-specific packages:
    /// - Linux: `swift-iso-9945` (`ISO_9945.Kernel.Copy.Clone.perform`)
    /// - macOS: `swift-iso-9945` (`ISO_9945.Kernel.Copy.Clone.file`)
    public enum Clone {}
}
