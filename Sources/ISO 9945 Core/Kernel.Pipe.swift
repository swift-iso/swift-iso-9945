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
    /// Anonymous pipe operations for inter-process/inter-thread communication.
    ///
    /// Creates unidirectional byte streams for communication. Data written to the
    /// write end can be read from the read end. Pipes are commonly used for:
    /// - Parent-child process communication
    /// - Inter-thread signaling
    /// - Implementing producer-consumer patterns
    ///
    /// ## Descriptor Lifecycle
    /// Both descriptors must be closed explicitly via ``Kernel/Close/close(_:)``.
    /// Close the write end to signal EOF to readers. Close the read end to cause
    /// writes to fail with EPIPE/SIGPIPE.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Pipe`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.Pipe`)
    public enum Pipe: Sendable {}
}
