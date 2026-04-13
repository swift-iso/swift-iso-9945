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

extension ISO_9945 {
    /// POSIX glob interface.
    ///
    /// Provides access to `fnmatch(3)` and `glob(3)` functionality
    /// on POSIX-compliant systems (Darwin, Linux).
    public enum Glob: Sendable {}
}
