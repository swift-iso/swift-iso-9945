// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel {
    /// I/O multiplexing via `poll(2)`.
    ///
    /// Monitors multiple file descriptors for readiness events without blocking
    /// on any single descriptor. The fundamental building block for event-driven I/O.
    public enum Poll {}
}
