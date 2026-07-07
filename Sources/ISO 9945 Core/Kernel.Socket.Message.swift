// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.Socket {
    /// Socket message operations and types.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Socket.Message`)
    /// - Linux: `swift-linux-primitives` (`Linux.Kernel.Socket.Message`)
    /// - Darwin: `swift-darwin-primitives` (`Darwin.Kernel.Socket.Message`)
    public struct Message: Sendable {}
}
