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
    /// Hard link operations.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Link`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.Link`)
    public enum Link {}
}

// MARK: - Count

extension ISO_9945.Kernel.Link {
    /// Hard link count for a file.
    public typealias Count = Tagged<ISO_9945.Kernel.Link, Cardinal>
}

