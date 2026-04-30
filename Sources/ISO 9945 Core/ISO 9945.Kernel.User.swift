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
    /// POSIX user-related types.
    public enum User: Sendable {}
}

extension ISO_9945.Kernel.User {
    /// POSIX user identifier (`uid_t` width: `UInt32`).
    ///
    /// `UInt32` matches the POSIX `uid_t` width 1:1. Used in file
    /// ownership and permission checks.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let stats = try Kernel.File.Stats.get(path)
    /// if stats.uid == .root {
    ///     // File is owned by root
    /// }
    /// ```
    public typealias ID = Tagged<ISO_9945.Kernel.User, UInt32>
}

extension Tagged where Tag == ISO_9945.Kernel.User, RawValue == UInt32 {
    /// The root user (uid 0).
    public static var root: Self { .zero }
}
