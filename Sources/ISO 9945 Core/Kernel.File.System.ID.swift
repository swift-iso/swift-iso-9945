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
    /// Filesystem identifier.
    ///
    /// On POSIX systems, this is derived from `f_fsid`.
    /// On Windows, this is the volume serial number.
    public typealias ID = Tagged<ISO_9945.Kernel.File.System, UInt64>
}

