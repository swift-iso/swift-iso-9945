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

extension Kernel.File {
    /// Path resolution operations for *at() syscall variants.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - Linux: `swift-linux-primitives` (`Linux.Kernel.File.At`)
    /// - Darwin: `swift-darwin-primitives` (`Darwin.Kernel.File.At`)
    public struct At: Sendable {}
}
