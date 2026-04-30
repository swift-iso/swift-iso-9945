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


extension ISO_9945.Kernel {
    /// Socket operations and types.
    ///
    /// Provides low-level socket syscall wrappers. For higher-level networking,
    /// see swift-networking which builds on these primitives.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Socket`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.Socket`)
    public enum Socket: Sendable {}
}

