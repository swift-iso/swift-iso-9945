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


extension ISO_9945.Kernel.Glob.Options.Error {
    /// Error handling policy during traversal.
    public enum Policy: Sendable, Hashable {
        /// Stop and throw on first error.
        case fail

        /// Skip inaccessible paths, continue collecting results.
        case skip
    }
}

