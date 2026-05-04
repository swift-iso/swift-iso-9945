// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Tagged_Primitives

extension ISO_9945.Kernel {
    /// POSIX group-related types.
    public enum Group: Sendable {}
}

extension ISO_9945.Kernel.Group {
    /// POSIX group identifier (`gid_t` width: `UInt32`).
    ///
    /// `UInt32` matches the POSIX `gid_t` width 1:1. Used in file
    /// ownership and permission checks.
    public typealias ID = Tagged<ISO_9945.Kernel.Group, UInt32>
}

extension Tagged where Tag == ISO_9945.Kernel.Group, Underlying == UInt32 {
    /// The root group (gid 0).
    public static var root: Self { .zero }
}
