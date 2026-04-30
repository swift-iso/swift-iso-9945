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

extension ISO_9945.Kernel.Descriptor.Validity {
    /// POSIX descriptor validity errors.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// The file descriptor is invalid (POSIX `EBADF`).
        case invalid

        /// File descriptor exhaustion (POSIX `EMFILE`/`ENFILE`).
        case limit(Limit)
    }
}

extension ISO_9945.Kernel.Descriptor.Validity.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .invalid:
            return "invalid descriptor"
        case .limit(let limit):
            return limit.description
        }
    }
}
