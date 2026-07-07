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
    /// IO domain - I/O operation errors.
    ///
    /// These errors indicate failures during actual I/O operations,
    /// distinct from path resolution or permission errors.
    public enum IO: Sendable {

    }
}

extension ISO_9945.Kernel.IO {
    /// Read operations.
    public enum Read: Sendable {}

    /// Write operations.
    public enum Write: Sendable {}

    /// Blocking-mode I/O state errors.
    public enum Blocking: Sendable {}
}
