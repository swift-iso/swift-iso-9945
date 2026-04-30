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


extension ISO_9945.Kernel.Socket {
    /// POSIX socket descriptor — typealiased to `ISO_9945.Kernel.Descriptor`.
    ///
    /// On POSIX, sockets ARE file descriptors: `socket(2)` returns an `int`
    /// closeable via `close(2)`. The L1-era distinction between
    /// `ISO_9945.Kernel.Descriptor` and `ISO_9945.Kernel.Socket.Descriptor` was a typing
    /// convenience; on POSIX the underlying lifecycle is the same.
    ///
    /// Per Cycle 21 (user direction 2026-04-30), typed handles relocate
    /// to L2 spec packages: this typealias lives at swift-iso-9945
    /// (POSIX) alongside the syscall implementations that use it.
    /// On Windows, `Windows.Kernel.Socket.Descriptor` at
    /// swift-windows-standard is a separate struct with `closesocket`
    /// deinit. The cross-platform name `ISO_9945.Kernel.Socket.Descriptor`
    /// resolves to either via the `#if`-gated typealias chain at
    /// swift-kernel L3.
    public typealias Descriptor = ISO_9945.Kernel.Descriptor
}
