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

extension ISO_9945.Kernel {
    /// Raw thread syscall wrappers.
    ///
    /// This namespace provides policy-free wrappers for platform thread primitives.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Thread`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.Thread`)
    public enum Thread {}
}
