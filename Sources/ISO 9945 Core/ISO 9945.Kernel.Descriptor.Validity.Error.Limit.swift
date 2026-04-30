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

extension ISO_9945.Kernel.Descriptor.Validity.Error {
    /// Limit scope for POSIX file descriptor exhaustion.
    public enum Limit: Sendable, Equatable, Hashable {
        /// Per-process file descriptor limit reached (POSIX `EMFILE`).
        case process

        /// System-wide file descriptor limit reached (POSIX `ENFILE`).
        case system
    }
}

extension ISO_9945.Kernel.Descriptor.Validity.Error.Limit: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .process:
            return "too many open files in process"
        case .system:
            return "too many open files in system"
        }
    }
}
