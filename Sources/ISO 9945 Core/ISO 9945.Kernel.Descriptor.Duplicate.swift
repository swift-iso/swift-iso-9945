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

extension ISO_9945.Kernel.Descriptor {
    /// POSIX descriptor duplication operations.
    ///
    /// Wraps `dup(2)` / `dup2(2)`. The new descriptor refers to the same
    /// open file and shares file offset and status flags.
    public enum Duplicate: Sendable {}
}

extension ISO_9945.Kernel.Descriptor.Duplicate {
    /// Errors that can occur during POSIX descriptor duplication.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The source descriptor is invalid.
        case handle(ISO_9945.Kernel.Descriptor.Validity.Error)

        /// Per-process file descriptor limit reached.
        case tooManyOpen

        /// A platform-specific error.
        case platform(Error_Primitives.Error)
    }
}
